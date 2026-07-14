const registerSystemLogSubscriber = require('./subscribers/systemLog.subscriber');

function registerSubscribers() {
  registerSystemLogSubscriber();
}

module.exports = registerSubscribers;
