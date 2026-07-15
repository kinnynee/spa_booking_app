const { getDb } = require('../../config/database');
const userModel = require('./user.model');

async function findById(id) {
  return getDb()(userModel.tableName).where({ id }).first();
}

async function findByEmail(email) {
  return getDb()(userModel.tableName).where({ email }).first();
}

async function findByGoogleSubject(googleSubject) {
  return getDb()(userModel.tableName).where({ google_subject: googleSubject }).first();
}

async function list({ limit = 50, offset = 0 } = {}) {
  const db = getDb();

  return db('users as users')
    .leftJoin('bookings as bookings', 'bookings.user_id', 'users.id')
    .select(
      'users.id',
      'users.full_name',
      'users.email',
      'users.phone',
      'users.role',
      'users.is_active',
      'users.created_at',
      db.raw(
        "count(bookings.id) filter (where bookings.status <> 'cancelled')::int as total_bookings",
      ),
      db.raw(
        "coalesce(sum(bookings.total_price) filter (where bookings.status <> 'cancelled' and bookings.payment_status = 'paid'), 0)::bigint as total_spent",
      ),
    )
    .groupBy(
      'users.id',
      'users.full_name',
      'users.email',
      'users.phone',
      'users.role',
      'users.is_active',
      'users.created_at',
    )
    .orderBy('users.created_at', 'desc')
    .limit(limit)
    .offset(offset);
}

async function createWithProfile(payload) {
  const db = getDb();

  return db.transaction(async (trx) => {
    const [user] = await trx(userModel.tableName)
      .insert({
        full_name: payload.fullName,
        email: payload.email,
        phone: payload.phone,
        password_hash: payload.passwordHash,
        google_subject: payload.googleSubject || null,
        role: payload.role,
      })
      .returning('*');

    await trx('profiles').insert({
      user_id: user.id,
      avatar_url: payload.avatarUrl || null,
    });

    return user;
  });
}

async function setGoogleSubject(id, googleSubject) {
  const [user] = await getDb()(userModel.tableName)
    .where({ id })
    .update({ google_subject: googleSubject })
    .returning('*');
  return user;
}

module.exports = {
  createWithProfile,
  findByEmail,
  findByGoogleSubject,
  findById,
  list,
  setGoogleSubject,
};
