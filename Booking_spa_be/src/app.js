const compression = require('compression');
const express = require('express');

const config = require('./config/env');
const { staticMiddleware } = require('./config/static-paths');
const { registerSystemSubscribers } = require('./common/events/system.subscriber');
const { errorHandler } = require('./common/middlewares/error.middleware');
const { inputGuard } = require('./common/middlewares/input-guard.middleware');
const { notFoundHandler } = require('./common/middlewares/not-found.middleware');
const { requestId } = require('./common/middlewares/request-id.middleware');
const { requestLogger } = require('./common/middlewares/request-logger.middleware');
const {
  corsMiddleware,
  globalRateLimiter,
  helmetMiddleware,
  hppMiddleware,
} = require('./common/middlewares/security.middleware');
const routes = require('./routes');

registerSystemSubscribers();

const app = express();

app.disable('x-powered-by');

app.use(requestId);
app.use(requestLogger);
app.use(helmetMiddleware);
app.use(corsMiddleware);
app.use(globalRateLimiter);
app.use(hppMiddleware);
app.use(express.json({ limit: config.app.jsonBodyLimit }));
app.use(express.urlencoded({ extended: false, limit: config.app.jsonBodyLimit }));
app.use(inputGuard);
app.use(compression());
app.use('/static', staticMiddleware);

app.use(config.app.apiPrefix, routes);
app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;
