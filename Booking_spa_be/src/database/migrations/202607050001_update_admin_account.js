exports.up = async function up(knex) {
  await knex('users').where({ email: 'admin@spa.local' }).update({
    full_name: 'Trần Trung Kiên',
    role: 'admin',
    is_active: true,
  });
};

exports.down = async function down(knex) {
  await knex('users').where({ email: 'admin@spa.local' }).update({
    full_name: 'System Admin',
  });
};
