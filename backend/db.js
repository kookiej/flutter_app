'use strict';

const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  charset: 'utf8mb4',
});

// schema.sql 기준 — 없는 경우에만 생성
async function ensureSchema() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id               CHAR(36)     NOT NULL DEFAULT (UUID())
                                    COMMENT '내부 PK (UUID). 외부 노출/타 테이블 FK용',
      spotify_user_id  VARCHAR(255) NOT NULL
                                    COMMENT 'GET /me 응답의 id. 유일한 신뢰 가능 식별자',
      display_name     VARCHAR(100) NULL
                                    COMMENT 'GET /me 응답의 display_name (null 가능). 유저가 서비스 내에서 수정 가능',
      pfp_url          VARCHAR(512) NULL
                                    COMMENT 'GET /me 응답의 images[0].url (profile picture)',
      created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                                    ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY uq_spotify_user_id (spotify_user_id)
    ) ENGINE=InnoDB
      DEFAULT CHARSET=utf8mb4
      COLLATE=utf8mb4_unicode_ci
      COMMENT='fanchant.ly 유저 (Spotify 계정 기반)'
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS user_spotify_tokens (
      user_id        CHAR(36)     NOT NULL
                                  COMMENT 'users.id FK (1:1)',
      access_token   TEXT         NOT NULL
                                  COMMENT 'Spotify access token (약 1시간 유효)',
      refresh_token  TEXT         NOT NULL
                                  COMMENT 'Spotify refresh token. 갱신 응답에 새 값이 오면 교체',
      expires_at     DATETIME     NOT NULL
                                  COMMENT 'access_token 만료 시각 (발급시각 + expires_in)',
      scope          VARCHAR(512) NULL
                                  COMMENT '부여된 스코프 목록 (공백 구분)',
      is_premium     TINYINT(1)   NOT NULL DEFAULT 0
                                  COMMENT 'GET /me product == "premium" 캐시. Web Playback SDK 분기용. product 필드 deprecated 주의',
      updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (user_id),
      CONSTRAINT fk_spotify_tokens_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
    ) ENGINE=InnoDB
      DEFAULT CHARSET=utf8mb4
      COLLATE=utf8mb4_unicode_ci
      COMMENT='유저별 Spotify OAuth 토큰'
  `);

  // tracks: 곡 메타데이터 (브라우즈/검색/존재여부 질의용)
  await pool.query(`
    CREATE TABLE IF NOT EXISTS tracks (
      spotify_track_id   VARCHAR(255) NOT NULL
                                      COMMENT 'Spotify track id. 재생/연동 키',
      title              VARCHAR(255) NULL COMMENT 'Spotify 메타 캐시',
      artist_name        VARCHAR(255) NULL COMMENT '대표 아티스트명 캐시 (필터/검색용)',
      album_name         VARCHAR(255) NULL,
      duration_ms        INT          NULL,
      has_synced_lyrics  TINYINT(1)   NOT NULL DEFAULT 0
                                      COMMENT '동기화 가사 보유 여부',
      has_fanchant       TINYINT(1)   NOT NULL DEFAULT 0
                                      COMMENT '응원법 보유 여부 (필터링용)',
      created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                                      ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (spotify_track_id),
      KEY idx_artist (artist_name),
      KEY idx_has_fanchant (has_fanchant)
    ) ENGINE=InnoDB
      DEFAULT CHARSET=utf8mb4
      COLLATE=utf8mb4_unicode_ci
      COMMENT='곡 메타데이터'
  `);

  // track_sync_data: 동기화된 가사+응원법 콘텐츠 (1:1)
  await pool.query(`
    CREATE TABLE IF NOT EXISTS track_sync_data (
      spotify_track_id  VARCHAR(255) NOT NULL,
      lyrics            JSON         NULL
                                     COMMENT '원본 동기화 가사 (재머지용 소스)',
      fanchant          JSON         NULL
                                     COMMENT '원본 응원법 (재머지용 소스)',
      sync_data         JSON         NOT NULL
                                     COMMENT '가사+응원법 사전 머지 결과',
      sync_version      INT          NOT NULL DEFAULT 1
                                     COMMENT '재생성 시 증가. 클라이언트 캐시 무효화 키로 사용',
      generated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (spotify_track_id),
      CONSTRAINT fk_fanchant_track
        FOREIGN KEY (spotify_track_id) REFERENCES tracks(spotify_track_id)
        ON DELETE CASCADE
    ) ENGINE=InnoDB
      DEFAULT CHARSET=utf8mb4
      COLLATE=utf8mb4_unicode_ci
      COMMENT='동기화된 콘텐츠'
  `);
}

module.exports = { pool, ensureSchema };
