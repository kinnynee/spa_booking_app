const BaseRepository = require('./base.repository');

class UserRepository extends BaseRepository {
  constructor() {
    super('users');
  }

  async createProfile(user) {
    return this.create(user, user.uid);
  }

  async findByEmail(email) {
    const snapshot = await this.collection.where('email', '==', email).limit(1).get();
    if (snapshot.empty) return null;
    const [doc] = snapshot.docs;
    return { id: doc.id, ...doc.data() };
  }

  async listUsers({ role, limit = 20 } = {}) {
    let query = this.collection.orderBy('createdAt', 'desc').limit(limit);
    if (role) query = this.collection.where('role', '==', role).limit(limit);

    const snapshot = await query.get();
    return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  }
}

module.exports = new UserRepository();
