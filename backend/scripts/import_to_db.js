'use strict';

// 로컬 output/{lyrics,fanchant,merged} 데이터를 읽어 Spotify 로 곡을 매칭한 뒤
// tracks(메타) + track_sync_data(싱크) 테이블에 적재한다.
//   사용: cd backend && npm run import

const fs = require('fs');
const fsp = require('fs/promises');
const path = require('path');
const axios = require('axios');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const { pool, ensureSchema } = require('../db');
const { mergeLyricsAndChant } = require('./merge');

const OUTPUT_DIR = path.join(__dirname, 'output');
const LYRICS_DIR = path.join(OUTPUT_DIR, 'lyrics');
const FANCHANT_DIR = path.join(OUTPUT_DIR, 'fanchant');
const MERGED_DIR = path.join(OUTPUT_DIR, 'merged');

const CLIENT_ID = process.env.SPOTIFY_CLIENT_ID;
const CLIENT_SECRET = process.env.SPOTIFY_CLIENT_SECRET;

// ─── Spotify Client Credentials 토큰 (카탈로그 검색용, 유저 컨텍스트 아님) ──────
let cachedToken = null; // { accessToken, expiresAt(ms) }

async function getToken() {
  if (cachedToken && cachedToken.expiresAt > Date.now() + 60_000) {
    return cachedToken.accessToken;
  }
  const basic = Buffer.from(`${CLIENT_ID}:${CLIENT_SECRET}`).toString('base64');
  const res = await axios.post(
    'https://accounts.spotify.com/api/token',
    new URLSearchParams({ grant_type: 'client_credentials' }).toString(),
    {
      headers: {
        Authorization: `Basic ${basic}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    }
  );
  const { access_token, expires_in } = res.data;
  cachedToken = {
    accessToken: access_token,
    expiresAt: Date.now() + expires_in * 1000,
  };
  return access_token;
}

// 파일명 "Artist - Title" → { artist, title }. " - " 가 없으면 전체를 title 로.
function parseBase(base) {
  const idx = base.indexOf(' - ');
  if (idx === -1) return { artist: '', title: base };
  return { artist: base.slice(0, idx), title: base.slice(idx + 3) };
}

// Spotify 검색 → 첫 트랙 메타. 결과 없으면 null.
async function searchTrack(artist, title) {
  const token = await getToken();
  const q = artist ? `track:${title} artist:${artist}` : `track:${title}`;
  const res = await axios.get('https://api.spotify.com/v1/search', {
    params: { q, type: 'track', limit: 1, market: 'KR' },
    headers: { Authorization: `Bearer ${token}` },
  });
  const item = res.data?.tracks?.items?.[0];
  if (!item) return null;
  return {
    spotifyTrackId: item.id,
    title: item.name,
    artistName: item.artists?.[0]?.name ?? null,
    albumName: item.album?.name ?? null,
    durationMs: item.duration_ms ?? null,
  };
}

async function readJson(filePath) {
  return JSON.parse(await fsp.readFile(filePath, 'utf8'));
}

// 한 곡 적재. 적재되면 true, 매칭 실패로 스킵되면 false.
async function importSong(base) {
  const { artist, title } = parseBase(base);

  const meta = await searchTrack(artist, title);
  if (!meta) {
    console.warn(`[skip] ${base}: Spotify 매칭 실패`);
    return false;
  }

  // 로컬 파일 로드
  const lyrics = await readJson(path.join(LYRICS_DIR, `${base}.json`));

  const fanchantPath = path.join(FANCHANT_DIR, `${base}.json`);
  const hasFanchant = fs.existsSync(fanchantPath);
  const fanchant = hasFanchant ? await readJson(fanchantPath) : null;

  // sync_data: merged 파일이 있으면 그대로, 없으면 lyrics-only 머지 생성
  const mergedPath = path.join(MERGED_DIR, `${base}.json`);
  const syncData = fs.existsSync(mergedPath)
    ? await readJson(mergedPath)
    : mergeLyricsAndChant(lyrics, []);

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    await conn.query(
      `INSERT INTO tracks
         (spotify_track_id, title, artist_name, album_name, duration_ms,
          has_synced_lyrics, has_fanchant)
       VALUES (?, ?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         title             = VALUES(title),
         artist_name       = VALUES(artist_name),
         album_name        = VALUES(album_name),
         duration_ms       = VALUES(duration_ms),
         has_synced_lyrics = VALUES(has_synced_lyrics),
         has_fanchant      = VALUES(has_fanchant)`,
      [
        meta.spotifyTrackId,
        meta.title,
        meta.artistName,
        meta.albumName,
        meta.durationMs,
        1,
        hasFanchant ? 1 : 0,
      ]
    );

    await conn.query(
      `INSERT INTO track_sync_data
         (spotify_track_id, lyrics, fanchant, sync_data)
       VALUES (?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         lyrics       = VALUES(lyrics),
         fanchant     = VALUES(fanchant),
         sync_data    = VALUES(sync_data),
         sync_version = sync_version + 1`,
      [
        meta.spotifyTrackId,
        JSON.stringify(lyrics),
        fanchant === null ? null : JSON.stringify(fanchant),
        JSON.stringify(syncData),
      ]
    );

    await conn.commit();
  } catch (e) {
    await conn.rollback();
    throw e;
  } finally {
    conn.release();
  }

  console.log(
    `[ok] ${base} → ${meta.spotifyTrackId} (${meta.artistName} - ${meta.title}, fanchant ${hasFanchant ? 'Y' : 'N'})`
  );
  return true;
}

async function main() {
  if (!CLIENT_ID || !CLIENT_SECRET) {
    console.error('[import] SPOTIFY_CLIENT_ID / SPOTIFY_CLIENT_SECRET 가 .env 에 없습니다.');
    process.exit(1);
  }
  if (!fs.existsSync(LYRICS_DIR)) {
    console.error(`[import] lyrics 디렉터리 없음: ${LYRICS_DIR} (먼저 npm run sync 실행)`);
    process.exit(1);
  }

  await ensureSchema();

  const files = (await fsp.readdir(LYRICS_DIR)).filter((f) => f.endsWith('.json'));
  console.log(`[import] lyrics 파일 ${files.length}개 발견`);

  let done = 0;
  for (const file of files) {
    const base = file.slice(0, -'.json'.length);
    try {
      if (await importSong(base)) done++;
    } catch (e) {
      console.error(`[error] ${base}: ${e.response?.data ? JSON.stringify(e.response.data) : e.message}`);
    }
  }
  console.log(`[import] 적재 완료: ${done}/${files.length}`);
}

main()
  .catch((e) => {
    console.error('[import] 실패:', e);
    process.exitCode = 1;
  })
  .finally(() => pool.end());
