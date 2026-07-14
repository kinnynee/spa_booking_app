const BaseRepository = require('./base.repository');

const allowedOrderFields = new Set(['createdAt', 'price', 'durationMinutes', 'name']);

class ServiceRepository extends BaseRepository {
  constructor() {
    super('services');
  }

  async listServices({ category, isPopular, isActive = true, limit = 20, orderBy = 'createdAt' } = {}) {
    const safeOrderBy = allowedOrderFields.has(orderBy) ? orderBy : 'createdAt';
    let query = this.collection.where('isActive', '==', isActive);

    if (category) query = query.where('category', '==', category);
    if (typeof isPopular === 'boolean') query = query.where('isPopular', '==', isPopular);

    const snapshot = await query.orderBy(safeOrderBy, 'desc').limit(limit).get();
    return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  }
}

module.exports = new ServiceRepository();
