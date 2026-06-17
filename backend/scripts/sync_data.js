'use strict';

// fanchant.ly 레포의 result/chant 파일을 lyrics/fanchant/merged 로 가공한 뒤
// 서버(SFTP)의 SFTP_BASE/{lyrics,fanchant,merged} 로 업로드한다.
//   사용: cd backend && npm run sync

const fs = require('fs');
const fsp = require('fs/promises');
const path = require('path');
const SftpClient = require('ssh2-sftp-client');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const { mergeLyricsAndChant } = require('./merge');

const FANCHANT_REPO = process.env.FANCHANT_REPO;
if (!FANCHANT_REPO) {
  console.error('[sync] FANCHANT_REPO 가 .env 에 설정되지 않았습니다.');
  process.exit(1);
}

const RESULT_DIR = path.join(FANCHANT_REPO, 'data', 'results', 'file');
const CHANT_DIR = path.join(FANCHANT_REPO, 'data', 'resources', 'chant');
const OUTPUT_DIR = path.join(__dirname, 'output');
const SUBDIRS = ['lyrics', 'fanchant', 'merged'];

const SFTP_BASE = process.env.SFTP_BASE || '/home/chaeyeon/dotmusic/sync_data';

// JSON 을 한글 보존(유니코드 이스케이프 없이) 2-space pretty 로 저장
async function writeJson(filePath, data) {
  await fsp.writeFile(filePath, JSON.stringify(data, null, 2), 'utf8');
}

// 로컬 output/{lyrics,fanchant,merged} 를 비우고 새로 만든다
async function prepareOutputDirs() {
  await fsp.rm(OUTPUT_DIR, { recursive: true, force: true });
  for (const sub of SUBDIRS) {
    await fsp.mkdir(path.join(OUTPUT_DIR, sub), { recursive: true });
  }
}

// 곡 한 곡을 가공해 세 폴더에 작성. 처리되면 true, 스킵되면 false.
async function processSong(base) {
  // 1) lyrics: result.resultData.text → [{ time, text }]
  const resultRaw = await fsp.readFile(
    path.join(RESULT_DIR, `${base}_result.json`),
    'utf8'
  );
  const result = JSON.parse(resultRaw);
  const textArr = result?.resultData?.text;
  if (!Array.isArray(textArr)) {
    console.warn(`[skip] ${base}: resultData.text 없음`);
    return false;
  }
  const lyrics = textArr.map((l) => ({ time: parseFloat(l.time), text: l.text }));
  await writeJson(path.join(OUTPUT_DIR, 'lyrics', `${base}.json`), lyrics);

  // 2) fanchant: chant 파일이 없으면 fanchant/merged 둘 다 생성하지 않고 lyrics만 둔다.
  const chantPath = path.join(CHANT_DIR, `${base}.json`);
  if (!fs.existsSync(chantPath)) {
    console.log(`[skip merge] ${base}: fanchant 없음 (lyrics ${lyrics.length})`);
    return true;
  }
  const fanchant = JSON.parse(await fsp.readFile(chantPath, 'utf8'));
  await writeJson(path.join(OUTPUT_DIR, 'fanchant', `${base}.json`), fanchant);

  // 3) merged: background.js fetchData 병합 로직
  const merged = mergeLyricsAndChant(lyrics, fanchant);
  await writeJson(path.join(OUTPUT_DIR, 'merged', `${base}.json`), merged);

  console.log(
    `[ok] ${base}  (lyrics ${lyrics.length}, fanchant ${fanchant.length}, merged ${merged.length})`
  );
  return true;
}

// output/{lyrics,fanchant,merged} 를 SFTP_BASE/* 로 업로드
async function upload() {
  const sftp = new SftpClient();
  await sftp.connect({
    host: process.env.SFTP_HOST,
    port: Number(process.env.SFTP_PORT) || 22,
    username: process.env.SFTP_USER,
    password: process.env.SFTP_PASSWORD,
  });
  try {
    for (const sub of SUBDIRS) {
      const remote = `${SFTP_BASE}/${sub}`;
      await sftp.mkdir(remote, true); // 상위 포함 보장 (이미 있으면 무시)
      await sftp.uploadDir(path.join(OUTPUT_DIR, sub), remote);
      console.log(`[upload] ${sub} → ${remote}`);
    }
  } finally {
    await sftp.end();
  }
}

async function main() {
  if (!fs.existsSync(RESULT_DIR)) {
    console.error(`[sync] result 디렉터리 없음: ${RESULT_DIR}`);
    process.exit(1);
  }

  await prepareOutputDirs();

  const files = (await fsp.readdir(RESULT_DIR)).filter((f) =>
    f.endsWith('_result.json')
  );
  console.log(`[sync] result 파일 ${files.length}개 발견`);

  let done = 0;
  for (const file of files) {
    const base = file.slice(0, -'_result.json'.length);
    try {
      if (await processSong(base)) done++;
    } catch (e) {
      console.error(`[error] ${base}: ${e.message}`);
    }
  }
  console.log(`[sync] 가공 완료: ${done}/${files.length}`);

  if (done === 0) {
    console.warn('[sync] 업로드할 파일이 없어 종료합니다.');
    return;
  }

  await upload();
  console.log('[sync] 모든 작업 완료.');
}

main().catch((e) => {
  console.error('[sync] 실패:', e);
  process.exit(1);
});
