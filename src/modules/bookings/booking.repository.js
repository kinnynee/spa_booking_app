const { getDb } = require('../../config/database');
const bookingModel = require('./booking.model');

async function create(payload) {
  const [booking] = await getDb()(bookingModel.tableName).insert(payload).returning('*');
  return booking;
}

async function findById(id) {
  return getDb()(bookingModel.tableName).where({ id }).first();
}

async function listByUserId(userId) {
  return getDb()(`${bookingModel.tableName} as bookings`)
    .join('spa_services as services', 'services.id', 'bookings.service_id')
    .where('bookings.user_id', userId)
    .select(
      'bookings.*',
      'services.name as service_name',
      'services.duration_minutes as service_duration_minutes',
    )
    .orderBy('bookings.appointment_time', 'desc');
}

async function updateStatus(id, status, changedBy, reason = null) {
  const db = getDb();

  return db.transaction(async (trx) => {
    const current = await trx(bookingModel.tableName).where({ id }).first();

    if (!current) {
      return null;
    }

    const [booking] = await trx(bookingModel.tableName)
      .where({ id })
      .update({
        status,
        updated_at: trx.fn.now(),
      })
      .returning('*');

    await trx('booking_status_history').insert({
      booking_id: id,
      old_status: current.status,
      new_status: status,
      changed_by: changedBy,
      reason,
    });

    return booking;
  });
}

module.exports = {
  create,
  findById,
  listByUserId,
  updateStatus,
};
