const { getFirestore } = require('../config/firebase');

class BaseRepository {
  constructor(collectionName) {
    this.collectionName = collectionName;
  }

  get db() {
    return getFirestore();
  }

  get collection() {
    return this.db.collection(this.collectionName);
  }

  async create(data, id = null) {
    const now = new Date().toISOString();
    const docRef = id ? this.collection.doc(id) : this.collection.doc();
    const payload = {
      ...data,
      id: docRef.id,
      createdAt: now,
      updatedAt: now,
    };

    await docRef.set(payload);
    return payload;
  }

  async findById(id) {
    const snapshot = await this.collection.doc(id).get();
    if (!snapshot.exists) return null;
    return { id: snapshot.id, ...snapshot.data() };
  }

  async update(id, data) {
    const payload = {
      ...data,
      updatedAt: new Date().toISOString(),
    };

    await this.collection.doc(id).set(payload, { merge: true });
    return this.findById(id);
  }

  async delete(id) {
    await this.collection.doc(id).delete();
    return true;
  }

  async list({ limit = 20, orderBy = 'createdAt', direction = 'desc' } = {}) {
    const snapshot = await this.collection.orderBy(orderBy, direction).limit(limit).get();
    return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  }
}

module.exports = BaseRepository;
