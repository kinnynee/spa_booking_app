const path = require('path');
const multer = require('multer');
const env = require('../config/env');

const storage = multer.diskStorage({
  destination: path.resolve(process.cwd(), env.STATIC_DIR, 'uploads'),
  filename(_req, file, callback) {
    const safeName = file.originalname.replace(/[^a-zA-Z0-9.]/g, '-').toLowerCase();
    callback(null, `${Date.now()}-${safeName}`);
  },
});

const upload = multer({
  storage,
  limits: {
    fileSize: 3 * 1024 * 1024,
  },
  fileFilter(_req, file, callback) {
    if (!file.mimetype.startsWith('image/')) {
      return callback(new Error('Only image uploads are allowed'));
    }

    return callback(null, true);
  },
});

module.exports = upload;
