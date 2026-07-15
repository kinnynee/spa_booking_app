const EventEmitter = require('events');

class EventBus extends EventEmitter {
  publish(eventName, payload) {
    this.emit(eventName, payload);
  }

  subscribe(eventName, handler) {
    this.on(eventName, handler);
  }
}

module.exports = new EventBus();
