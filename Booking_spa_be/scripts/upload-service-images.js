/* eslint-disable no-console */
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const config = require('../src/config/env');
const { closeDb, getDb } = require('../src/config/database');
const { getStorage } = require('../src/config/firebase');

const serviceImages = [
  {
    slug: 'aroma-relax-massage',
    fileName: 'img_massage.jpg',
  },
  {
    slug: 'hydrating-facial-care',
    fileName: 'img_cham_soc_da_chuyensau.jpg',
  },
  {
    slug: 'hot-stone-therapy',
    fileName: 'img_trilieu_huongthom.jpg',
  },
];

const contentTypes = {
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
  '.webp': 'image/webp',
};

function resolveAssetDir() {
  if (process.env.SERVICE_IMAGE_ASSET_DIR) {
    return path.resolve(process.env.SERVICE_IMAGE_ASSET_DIR);
  }

  return path.resolve(__dirname, '..', '..', 'assets', 'images');
}

function createDownloadToken() {
  if (typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID();
  }

  return crypto.randomBytes(16).toString('hex');
}

function buildDownloadUrl(bucketName, destination, token) {
  const encodedPath = encodeURIComponent(destination);
  return `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodedPath}?alt=media&token=${token}`;
}

async function uploadServiceImage({ bucket, db, assetDir, serviceImage }) {
  const localPath = path.join(assetDir, serviceImage.fileName);

  if (!fs.existsSync(localPath)) {
    throw new Error(`Missing image file: ${localPath}`);
  }

  const extension = path.extname(serviceImage.fileName).toLowerCase();
  const destination = `service-images/${serviceImage.slug}${extension}`;
  const token = createDownloadToken();

  await bucket.upload(localPath, {
    destination,
    resumable: false,
    metadata: {
      cacheControl: 'public,max-age=31536000',
      contentType: contentTypes[extension] || 'application/octet-stream',
      metadata: {
        firebaseStorageDownloadTokens: token,
      },
    },
  });

  const imageUrl = buildDownloadUrl(bucket.name, destination, token);
  const updatedRows = await db('spa_services')
    .where({ slug: serviceImage.slug })
    .update({ image_url: imageUrl });

  return {
    ...serviceImage,
    destination,
    imageUrl,
    updatedRows,
  };
}

async function main() {
  if (!config.firebase.storageBucket) {
    throw new Error(
      'Missing FIREBASE_STORAGE_BUCKET in .env. Copy the bucket name from Firebase Console > Storage.',
    );
  }

  const assetDir = resolveAssetDir();

  if (!fs.existsSync(assetDir)) {
    throw new Error(`Missing asset directory: ${assetDir}`);
  }

  const db = getDb();
  const bucket = getStorage().bucket(config.firebase.storageBucket);
  const results = [];

  for (const serviceImage of serviceImages) {
    const result = await uploadServiceImage({ bucket, db, assetDir, serviceImage });
    results.push(result);
    console.log(
      `${result.updatedRows ? 'UPDATED' : 'SKIPPED'} ${result.slug} -> ${result.destination}`,
    );
  }

  const skipped = results.filter((result) => result.updatedRows === 0);

  if (skipped.length) {
    console.warn(
      `No database row found for slug(s): ${skipped.map((result) => result.slug).join(', ')}`,
    );
  }

  console.log(
    'Service image upload completed. Restart or refresh the Flutter app to reload service data.',
  );
}

main()
  .catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    await closeDb();
  });
