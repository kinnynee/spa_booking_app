const BaseRepository = require('./base.repository');

class PipelineCustomerRepository extends BaseRepository {
  constructor() {
    super('pipeline_customers');
  }
}

module.exports = new PipelineCustomerRepository();
