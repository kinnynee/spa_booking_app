const crypto = require('crypto');
const fs = require('fs/promises');
const path = require('path');

const { staticRoot } = require('../../config/static-paths');
const { AppError } = require('../../common/errors/app-error');

const imageTypes = {
  'image/jpeg': { extension: '.jpg', isValid: isJpeg },
  'image/png': { extension: '.png', isValid: isPng },
  'image/webp': { extension: '.webp', isValid: isWebp },
};

async function saveServiceImage({ buffer, contentType }) {
  const normalizedType = contentType.split(';', 1)[0].trim().toLowerCase();
  const imageType = imageTypes[normalizedType];
  if (!imageType) {
    throw new AppError(
      'Only JPEG, PNG, and WebP images are supported.',
      415,
      'UNSUPPORTED_IMAGE_TYPE',
    );
  }

  if (!Buffer.isBuffer(buffer) || buffer.length === 0) {
    throw new AppError('Image data is required.', 400, 'IMAGE_REQUIRED');
  }

  if (!imageType.isValid(buffer)) {
    throw new AppError('The uploaded file is not a valid image.', 400, 'INVALID_IMAGE');
  }

  const directory = path.join(staticRoot, 'uploads', 'services');
  await fs.mkdir(directory, { recursive: true });

  const fileName = `service-${crypto.randomUUID()}${imageType.extension}`;
  await fs.writeFile(path.join(directory, fileName), buffer, { flag: 'wx' });
  return fileName;
}

function isJpeg(buffer) {
  return buffer.length >= 3 && buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff;
}

function isPng(buffer) {
  const signature = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
  return buffer.length >= signature.length && signature.every((value, index) => buffer[index] === value);
}

function isWebp(buffer) {
  return buffer.length >= 12 &&
    buffer.subarray(0, 4).toString('ascii') === 'RIFF' &&
    buffer.subarray(8, 12).toString('ascii') === 'WEBP';
}

module.exports = {
  saveServiceImage,
};
