const createError = require('http-errors');
const BaseRepository = require('./base.repository');
const { AppointmentStatus } = require('../models/appointment.model');

class AppointmentRepository extends BaseRepository {
  constructor() {
    super('appointments');
  }

  async createAppointment(data) {
    const now = new Date().toISOString();
    const docRef = this.collection.doc();

    return this.db.runTransaction(async (transaction) => {
      if (data.staffId) {
        const conflictSnapshot = await transaction.get(
          this.collection
            .where('staffId', '==', data.staffId)
            .where('startAt', '==', data.startAt)
            .where('status', 'in', [AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED])
            .limit(1)
        );

        if (!conflictSnapshot.empty) {
          throw createError(409, 'Staff is already booked for this time slot');
        }
      }

      const payload = {
        ...data,
        id: docRef.id,
        createdAt: now,
        updatedAt: now,
      };

      transaction.set(docRef, payload);
      return payload;
    });
  }

  async listForCustomer(customerId, { limit = 20 } = {}) {
    const snapshot = await this.collection
      .where('customerId', '==', customerId)
      .orderBy('startAt', 'desc')
      .limit(limit)
      .get();

    return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  }

  async listForStaff(staffId, { limit = 20 } = {}) {
    const snapshot = await this.collection
      .where('staffId', '==', staffId)
      .orderBy('startAt', 'desc')
      .limit(limit)
      .get();

    return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  }

  async updateStatus(id, status) {
    return this.update(id, { status });
  }
}

module.exports = new AppointmentRepository();
