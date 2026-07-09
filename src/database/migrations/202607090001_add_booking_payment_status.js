exports.up = async function up(knex) {
  await knex.schema.alterTable('bookings', (table) => {
    table.string('payment_status', 30).notNullable().defaultTo('unpaid');
    table.timestamp('paid_at', { useTz: true });
  });

  await knex.raw(
    "alter table bookings add constraint bookings_payment_status_check check (payment_status in ('unpaid', 'paid'))",
  );
};

exports.down = async function down(knex) {
  await knex.raw('alter table bookings drop constraint if exists bookings_payment_status_check');

  await knex.schema.alterTable('bookings', (table) => {
    table.dropColumn('paid_at');
    table.dropColumn('payment_status');
  });
};
