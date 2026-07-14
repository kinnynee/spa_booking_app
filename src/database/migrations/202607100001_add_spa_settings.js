exports.up = async function up(knex) {
  await knex.schema.createTable('spa_settings', (table) => {
    table.integer('id').primary();
    table.string('spa_name', 140).notNullable().defaultTo('Lavender Spa');
    table.string('address', 255);
    table.string('hotline', 30);
    table.string('contact_email', 160);
    table.string('opening_time', 5).notNullable().defaultTo('09:00');
    table.string('closing_time', 5).notNullable().defaultTo('21:00');
    table.boolean('is_open_saturday').notNullable().defaultTo(true);
    table.boolean('is_open_sunday').notNullable().defaultTo(false);
    table.integer('booking_lead_minutes').notNullable().defaultTo(30);
    table.string('banner_title', 140).notNullable().defaultTo('Ưu đãi thư giãn hôm nay');
    table.string('banner_subtitle', 255).notNullable().defaultTo('Đặt lịch nhanh để nhận ưu đãi tại Lavender Spa.');
    table.string('banner_image_url', 500);
    table.timestamps(true, true);
  });

  await knex('spa_settings').insert({
    id: 1,
    spa_name: 'Lavender Spa',
    opening_time: '09:00',
    closing_time: '21:00',
    is_open_saturday: true,
    is_open_sunday: false,
    booking_lead_minutes: 30,
    banner_title: 'Ưu đãi thư giãn hôm nay',
    banner_subtitle: 'Đặt lịch nhanh để nhận ưu đãi tại Lavender Spa.',
  });
};

exports.down = async function down(knex) {
  await knex.schema.dropTableIfExists('spa_settings');
};
