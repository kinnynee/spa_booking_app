const BaseRepository = require('./base.repository');

class DlqRepository extends BaseRepository {
  constructor() {
    super('dead_letter_queue');
  }
}

module.exports = new DlqRepository();
