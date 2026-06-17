'use strict';

const express = require('express');
const axios = require('axios');
const path = require('path');
const jwt = require('jsonwebtoken');
require('dotenv').config({ path: path.join(__dirname, '.env') });

const { pool, ensureSchema } = require('./db');

const app = express();
const PORT = process.env.PORT || 8080;
const WEB_DIR = path.join(__dirname, '..', 'build', 'web');
const JWT_SECRET = process.env.JWT_SECRET;
const SPOTIFY_CLIENT_ID = process.env.SPOTIFY_CLIENT_ID;

app.use(express.json());

function origin(req) {
  return `${req.protocol}://${req.get('host')}`;
}

// ─── JWT auth middleware ─────────────────────────────────────────────────────
function requireAuth(req, res, next) {
  const header = req.get('authorization') || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'unauthorized' });
  try {
    const payload = jwt.verify(token, JWT_SECRET);
    req.userId = payload.sub;
    next();
  } catch {
    res.status(401).json({ error: 'unauthorized' });
  }
}

function rowToUser(row) {
  return {
    id: row.id,
    spotifyUserId: row.spotify_user_id,
    displayName: row.display_name,
    pfpUrl: row.pfp_url,
    isPremium: !!row.is_premium,
  };
}

// ─── Spotify: code 교환 + /me 조회 + DB upsert + JWT 발급 ────────────────────
app.post('/api/auth/spotify', async (req, res) => {
  const { code, code_verifier, redirect_uri } = req.body || {};
  if (!code || !code_verifier || !redirect_uri) {
    return res.status(400).json({ error: 'missing_params' });
  }

  try {
    // [6] code → token (PKCE: client secret 불필요)
    const tokenRes = await axios.post(
      'https://accounts.spotify.com/api/token',
      new URLSearchParams({
        grant_type: 'authorization_code',
        code,
        redirect_uri,
        client_id: SPOTIFY_CLIENT_ID,
        code_verifier,
      }).toString(),
      { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
    );
    const { access_token, refresh_token, expires_in, scope } = tokenRes.data;

    // [7] /me 프로필
    const meRes = await axios.get('https://api.spotify.com/v1/me', {
      headers: { Authorization: `Bearer ${access_token}` },
    });
    const me = meRes.data;
    const displayName = me.display_name ?? null;
    const pfpUrl = me.images?.[0]?.url ?? null;
    // product는 deprecated — 응답에 없으면 null로 두고 기존 값 유지
    const isPremium =
      me.product === undefined ? null : me.product === 'premium' ? 1 : 0;

    // [8] 트랜잭션 upsert
    const conn = await pool.getConnection();
    let userRow;
    try {
      await conn.beginTransaction();

      await conn.query(
        `INSERT INTO users (id, spotify_user_id, display_name, pfp_url)
         VALUES (UUID(), ?, ?, ?)
         ON DUPLICATE KEY UPDATE
           display_name = COALESCE(users.display_name, VALUES(display_name)),
           pfp_url      = VALUES(pfp_url)`,
        [me.id, displayName, pfpUrl]
      );

      const [[user]] = await conn.query(
        'SELECT id, spotify_user_id, display_name, pfp_url FROM users WHERE spotify_user_id = ?',
        [me.id]
      );

      await conn.query(
        `INSERT INTO user_spotify_tokens
           (user_id, access_token, refresh_token, expires_at, scope, is_premium)
         VALUES (?, ?, ?, DATE_ADD(NOW(), INTERVAL ? SECOND), ?, COALESCE(?, 0))
         ON DUPLICATE KEY UPDATE
           access_token  = VALUES(access_token),
           refresh_token = VALUES(refresh_token),
           expires_at    = VALUES(expires_at),
           scope         = VALUES(scope),
           is_premium    = COALESCE(?, user_spotify_tokens.is_premium)`,
        [user.id, access_token, refresh_token, expires_in, scope, isPremium, isPremium]
      );

      await conn.commit();
      userRow = user;
    } catch (e) {
      await conn.rollback();
      throw e;
    } finally {
      conn.release();
    }

    // [9] 자체 JWT 발급
    const token = jwt.sign({ sub: userRow.id }, JWT_SECRET, { expiresIn: '30d' });

    res.json({
      token,
      user: rowToUser({ ...userRow, is_premium: isPremium ?? 0 }),
    });
  } catch (e) {
    console.error('[Spotify auth] error:', e.response?.data ?? e.message);
    res.status(502).json({ error: 'spotify_auth_failed' });
  }
});

// ─── 현재 유저 정보 (login-flow.md 3-3) ──────────────────────────────────────
app.get('/api/me', requireAuth, async (req, res) => {
  try {
    const [[row]] = await pool.query(
      `SELECT u.id, u.spotify_user_id, u.display_name, u.pfp_url,
              t.is_premium,
              (t.user_id IS NOT NULL) AS spotify_connected
       FROM users u
       LEFT JOIN user_spotify_tokens t ON t.user_id = u.id
       WHERE u.id = ?`,
      [req.userId]
    );
    if (!row) return res.status(404).json({ error: 'not_found' });
    res.json({
      user: rowToUser(row),
      spotifyConnected: !!row.spotify_connected,
    });
  } catch (e) {
    console.error('[me] error:', e.message);
    res.status(500).json({ error: 'internal' });
  }
});

// ─── Spotify access token 조회/갱신 (login-flow.md 3-2) ──────────────────────
const inflightRefresh = new Map(); // userId → Promise (동시 갱신 1회 제한)

async function refreshSpotifyToken(userId, refreshToken) {
  const tokenRes = await axios.post(
    'https://accounts.spotify.com/api/token',
    new URLSearchParams({
      grant_type: 'refresh_token',
      refresh_token: refreshToken,
      client_id: SPOTIFY_CLIENT_ID,
    }).toString(),
    { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
  );
  const { access_token, expires_in, refresh_token: newRefresh } = tokenRes.data;

  await pool.query(
    `UPDATE user_spotify_tokens SET
       access_token  = ?,
       expires_at    = DATE_ADD(NOW(), INTERVAL ? SECOND),
       refresh_token = COALESCE(?, refresh_token)
     WHERE user_id = ?`,
    [access_token, expires_in, newRefresh ?? null, userId]
  );
  return access_token;
}

app.get('/api/spotify/token', requireAuth, async (req, res) => {
  try {
    const [[row]] = await pool.query(
      `SELECT access_token, refresh_token,
              (expires_at > DATE_ADD(NOW(), INTERVAL 60 SECOND)) AS still_valid
       FROM user_spotify_tokens WHERE user_id = ?`,
      [req.userId]
    );
    if (!row) return res.status(401).json({ error: 'reauth' });

    if (row.still_valid) {
      return res.json({ access_token: row.access_token });
    }

    let promise = inflightRefresh.get(req.userId);
    if (!promise) {
      promise = refreshSpotifyToken(req.userId, row.refresh_token).finally(() =>
        inflightRefresh.delete(req.userId)
      );
      inflightRefresh.set(req.userId, promise);
    }
    const accessToken = await promise;
    res.json({ access_token: accessToken });
  } catch (e) {
    const errBody = e.response?.data;
    console.error('[token] error:', errBody ?? e.message);
    if (errBody?.error === 'invalid_grant') {
      // 유저가 Spotify 쪽에서 앱 연결을 해제한 경우 → 재로그인 유도
      await pool.query('DELETE FROM user_spotify_tokens WHERE user_id = ?', [
        req.userId,
      ]);
      return res.status(401).json({ error: 'reauth' });
    }
    res.status(502).json({ error: 'refresh_failed' });
  }
});

// ─── Spotify 연동 해제 ───────────────────────────────────────────────────────
app.delete('/api/spotify/connection', requireAuth, async (req, res) => {
  try {
    await pool.query('DELETE FROM user_spotify_tokens WHERE user_id = ?', [
      req.userId,
    ]);
    res.json({ ok: true });
  } catch (e) {
    console.error('[disconnect] error:', e.message);
    res.status(500).json({ error: 'internal' });
  }
});

// ─── Kakao OAuth callback ────────────────────────────────────────────────────
app.get('/login/kakao/oauth', async (req, res) => {
  const { code, error } = req.query;

  if (error || !code) {
    console.warn('[Kakao] auth denied or missing code:', error);
    return res.redirect('/?kakao_error=true');
  }

  try {
    const redirectUri = `${origin(req)}/login/kakao/oauth`;

    // code → access_token
    const tokenRes = await axios.post(
      'https://kauth.kakao.com/oauth/token',
      new URLSearchParams({
        grant_type: 'authorization_code',
        client_id: process.env.KAKAO_REST_API_KEY,
        client_secret: process.env.KAKAO_CLIENT_SECRET,
        redirect_uri: redirectUri,
        code,
      }).toString(),
      { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
    );
    const { access_token } = tokenRes.data;

    // access_token → user profile
    const profileRes = await axios.get('https://kapi.kakao.com/v2/user/me', {
      headers: { Authorization: `Bearer ${access_token}` },
    });
    const { id, kakao_account } = profileRes.data;
    const nickname = kakao_account?.profile?.nickname ?? '';
    const profileImage = kakao_account?.profile?.profile_image_url ?? '';

    const params = new URLSearchParams({
      kakao_id: String(id),
      kakao_nickname: nickname,
      kakao_image: profileImage,
    });
    res.redirect(`/?${params}`);
  } catch (e) {
    console.error('[Kakao] error:', e.response?.data ?? e.message);
    res.redirect('/?kakao_error=true');
  }
});

// ─── Naver OAuth callback ────────────────────────────────────────────────────
app.get('/login/naver/oauth', async (req, res) => {
  const { code, state, error } = req.query;

  if (error || !code) {
    console.warn('[Naver] auth denied or missing code:', error);
    return res.redirect('/?naver_error=true');
  }

  try {
    // code → access_token
    const tokenRes = await axios.get('https://nid.naver.com/oauth2.0/token', {
      params: {
        grant_type: 'authorization_code',
        client_id: process.env.NAVER_CLIENT_ID,
        client_secret: process.env.NAVER_CLIENT_SECRET,
        code,
        state,
      },
    });
    const { access_token } = tokenRes.data;

    // access_token → user profile
    const profileRes = await axios.get('https://openapi.naver.com/v1/nid/me', {
      headers: { Authorization: `Bearer ${access_token}` },
    });
    const { id, email, nickname, profile_image } = profileRes.data.response;

    const params = new URLSearchParams({
      naver_id: id,
      naver_email: email ?? '',
      naver_nickname: nickname ?? '',
      naver_image: profile_image ?? '',
    });
    res.redirect(`/?${params}`);
  } catch (e) {
    console.error('[Naver] error:', e.response?.data ?? e.message);
    res.redirect('/?naver_error=true');
  }
});

// ─── 곡 가사/응원법 sync 데이터 조회 (재생 진입 시 1회) ──────────────────────
// 가사는 유저 종속 콘텐츠가 아니므로 인증 불필요.
app.get('/api/tracks/:id/sync', async (req, res) => {
  try {
    const [[row]] = await pool.query(
      `SELECT t.has_synced_lyrics, t.has_fanchant, s.sync_data
         FROM tracks t
         LEFT JOIN track_sync_data s ON s.spotify_track_id = t.spotify_track_id
        WHERE t.spotify_track_id = ?`,
      [req.params.id]
    );
    if (!row) return res.status(404).json({ error: 'not_found' });
    res.json({
      hasSyncedLyrics: !!row.has_synced_lyrics,
      hasFanchant: !!row.has_fanchant,
      // mysql2 의 JSON 컬럼은 객체로 파싱되어 오지만, 드라이버/설정에 따라 문자열일 수 있어 정규화
      syncData:
        typeof row.sync_data === 'string'
          ? JSON.parse(row.sync_data)
          : row.sync_data ?? null,
    });
  } catch (e) {
    console.error('[tracks/sync] error:', e.message);
    res.status(500).json({ error: 'internal' });
  }
});

// ─── Flutter web (SPA) ───────────────────────────────────────────────────────
app.use(express.static(WEB_DIR));

app.get('*', (_req, res) => {
  res.sendFile(path.join(WEB_DIR, 'index.html'));
});

ensureSchema()
  .then(() => {
    console.log('[db] schema ready');
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`[server] listening on http://0.0.0.0:${PORT}`);
    });
  })
  .catch((e) => {
    console.error('[db] schema init failed:', e);
    process.exit(1);
  });
