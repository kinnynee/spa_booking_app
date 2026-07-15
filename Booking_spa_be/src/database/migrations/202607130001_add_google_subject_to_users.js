exports.up = async function up(knex) {
  await knex.schema.alterTable('users', (table) => {
    table.string('google_subject', 255).unique();
  });
};

exports.down = async function down(knex) {
  await knex.schema.alterTable('users', (table) => {
    table.dropColumn('google_subject');
  });
};
