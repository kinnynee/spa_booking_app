const { getDb } = require('../../config/database');
const bookingModel = require('./booking.model');

function detailedQuery(db = getDb()) {
  return db(bookingModel.tableName + ' as bookings')
    .join('spa_services as services', 'services.id', 'bookings.service_id')
    .join('users as users', 'users.id', 'bookings.user_id')
    .select(
      'bookings.*',
      'services.name as service_name',
      'services.duration_minutes as service_duration_minutes',
      'users.full_name as customer_name',
      'users.phone as customer_phone',
      'users.email as customer_email',
    );
}

async function create(payload) {
  const [booking] = await getDb()(bookingModel.tableName).insert(payload).returning('*');
  return booking;
}

async function findById(id) {
  return getDb()(bookingModel.tableName).where({ id }).first();
}

async function findDetailedById(id) {
  return detailedQuery().where('bookings.id', id).first();
}

async function list(filters = {}) {
  const query = detailedQuery().orderBy('bookings.appointment_time', 'desc');

  if (filters.status) {
    query.where('bookings.status', filters.status);
  }

  if (filters.paymentStatus) {
    query.where('bookings.payment_status', filters.paymentStatus);
  }

  if (filters.search) {
    const keyword = '%' + filters.search + '%';
    query.andWhere((builder) => {
      builder
        .whereILike('users.full_name', keyword)
        .orWhereILike('users.phone', keyword)
        .orWhereILike('users.email', keyword)
        .orWhereILike('services.name', keyword);
    });
  }

  return query.limit(filters.limit ?? 100).offset(filters.offset ?? 0);
}

async function listByUserId(userId) {
  return getDb()(bookingModel.tableName + ' as bookings')
    .join('spa_services as services', 'services.id', 'bookings.service_id')
    .where('bookings.user_id', userId)
    .select(
      'bookings.*',
      'services.name as service_name',
      'services.duration_minutes as service_duration_minutes',
    )
    .orderBy('bookings.appointment_time', 'desc');
}

async function hasUserTimeConflict(userId, startsAt, endsAt) {
  const booking = await getDb()('bookings as bookings')
    .join('spa_services as services', 'services.id', 'bookings.service_id')
    .where('bookings.user_id', userId)
    .whereIn('bookings.status', [bookingModel.statuses.PENDING, bookingModel.statuses.CONFIRMED])
    .where('bookings.appointment_time', '<', endsAt)
    .whereRaw(
      "bookings.appointment_time + (services.duration_minutes * interval '1 minute') > ?",
      [startsAt],
    )
    .first('bookings.id');

  return Boolean(booking);
}

async function updatePaymentStatus(id, paymentStatus) {
  const db = getDb();
  const [booking] = await db(bookingModel.tableName)
    .where({ id })
    .update({
      payment_status: paymentStatus,
      paid_at: paymentStatus === bookingModel.paymentStatuses.PAID ? db.fn.now() : null,
      updated_at: db.fn.now(),
    })
    .returning('*');

  return booking ?? null;
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
  findDetailedById,
  hasUserTimeConflict,
  list,
  listByUserId,
  updatePaymentStatus,
  updateStatus,
};
