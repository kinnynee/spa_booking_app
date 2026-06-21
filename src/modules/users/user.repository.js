const { getDb } = require('../../config/database');
const userModel = require('./user.model');

async function findById(id) {
  return getDb()(userModel.tableName).where({ id }).first();
}

async function findByEmail(email) {
  return getDb()(userModel.tableName).where({ email }).first();
}

async function list({ limit = 50, offset = 0 } = {}) {
  return getDb()(userModel.tableName)
    .select('id', 'full_name', 'email', 'phone', 'role', 'is_active', 'created_at')
    .orderBy('created_at', 'desc')
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
        role: payload.role,
      })
      .returning('*');

    await trx('profiles').insert({
      user_id: user.id,
    });

    return user;
  });
}

module.exports = {
  createWithProfile,
  findByEmail,
  findById,
  list,
};
