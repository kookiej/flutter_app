'use strict';

const {
  S3Client,
  PutObjectCommand,
  DeleteObjectCommand,
} = require('@aws-sdk/client-s3');

const REGION = process.env.AWS_REGION || 'ap-northeast-2';
const BUCKET = process.env.S3_BUCKET;
// 프리픽스는 슬래시로 끝나도록 정규화 (예: "PFP/")
const PREFIX = (process.env.S3_PFP_PREFIX || 'PFP/').replace(/\/?$/, '/');

const s3 = new S3Client({
  region: REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

// 유저당 고정 키 → 새 사진이 이전 사진을 덮어쓴다(누적 방지).
function keyFor(userId) {
  return `${PREFIX}${userId}.jpg`;
}

function publicUrl(key) {
  return `https://${BUCKET}.s3.${REGION}.amazonaws.com/${key}`;
}

/// 이미지 버퍼를 S3에 업로드하고, 캐시 무효화 쿼리를 붙인 공개 URL을 반환.
async function uploadPfp(userId, buffer, contentType) {
  const key = keyFor(userId);
  await s3.send(
    new PutObjectCommand({
      Bucket: BUCKET,
      Key: key,
      Body: buffer,
      ContentType: contentType || 'image/jpeg',
    })
  );
  // 동일 키 덮어쓰기라 브라우저 캐시 무효화용 버전 쿼리를 붙인다
  return `${publicUrl(key)}?t=${Date.now()}`;
}

/// 유저의 프로필 사진 객체를 S3에서 제거. 이미 없어도 성공으로 간주.
async function deletePfp(userId) {
  await s3.send(
    new DeleteObjectCommand({ Bucket: BUCKET, Key: keyFor(userId) })
  );
}

module.exports = { uploadPfp, deletePfp };
