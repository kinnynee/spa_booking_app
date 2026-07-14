const express = require('express');
const path = require('path');

const staticRoot = path.join(__dirname, '..', '..', 'static');

const staticMiddleware = express.static(staticRoot, {
  fallthrough: true,
  index: false,
  maxAge: '7d',
});

module.exports = {
  staticRoot,
  staticMiddleware,
};
