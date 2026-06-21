exports.up = async function up(knex) {
  await knex.raw('create extension if not exists "pgcrypto"');

  await knex.raw(`
    create or replace function set_updated_at()
    returns trigger as $$
    begin
      new.updated_at = now();
      return new;
    end;
    $$ language plpgsql;
  `);

  await knex.schema.createTable('users', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.string('full_name', 120).notNullable();
    table.string('email', 160).notNullable().unique();
    table.string('phone', 20);
    table.string('password_hash', 255).notNullable();
    table.string('role', 30).notNullable().defaultTo('customer');
    table.boolean('is_active').notNullable().defaultTo(true);
    table.timestamps(true, true);
    table.check("role in ('admin', 'staff', 'customer')");
  });

  await knex.schema.createTable('profiles', (table) => {
    table.uuid('user_id').primary().references('id').inTable('users').onDelete('CASCADE');
    table.string('avatar_url', 500);
    table.date('birth_date');
    table.string('gender', 20);
    table.text('address');
    table.timestamps(true, true);
    table.check("gender is null or gender in ('male', 'female', 'other')");
  });

  await knex.schema.createTable('service_categories', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.string('name', 120).notNullable();
    table.string('slug', 140).notNullable().unique();
    table.text('description');
    table.integer('sort_order').notNullable().defaultTo(0);
    table.boolean('is_active').notNullable().defaultTo(true);
    table.timestamps(true, true);
  });

  await knex.schema.createTable('spa_services', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table
      .uuid('category_id')
      .notNullable()
      .references('id')
      .inTable('service_categories')
      .onDelete('RESTRICT');
    table.string('name', 160).notNullable();
    table.string('slug', 180).notNullable().unique();
    table.text('description');
    table.decimal('price', 12, 2).notNullable();
    table.integer('duration_minutes').notNullable();
    table.string('image_url', 500);
    table.boolean('is_popular').notNullable().defaultTo(false);
    table.boolean('is_active').notNullable().defaultTo(true);
    table.timestamps(true, true);
    table.check('price >= 0');
    table.check('duration_minutes > 0');
  });

  await knex.schema.createTable('bookings', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    table
      .uuid('service_id')
      .notNullable()
      .references('id')
      .inTable('spa_services')
      .onDelete('RESTRICT');
    table.timestamp('appointment_time', { useTz: true }).notNullable();
    table.text('note');
    table.string('status', 30).notNullable().defaultTo('pending');
    table.decimal('total_price', 12, 2).notNullable();
    table.timestamps(true, true);
    table.index(['user_id', 'appointment_time']);
    table.index(['service_id', 'appointment_time']);
    table.check("status in ('pending', 'confirmed', 'cancelled', 'completed')");
    table.check('total_price >= 0');
  });

  await knex.schema.createTable('booking_status_history', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('booking_id').notNullable().references('id').inTable('bookings').onDelete('CASCADE');
    table.string('old_status', 30);
    table.string('new_status', 30).notNullable();
    table.uuid('changed_by').references('id').inTable('users').onDelete('SET NULL');
    table.string('reason', 255);
    table.timestamp('created_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());
  });

  await knex.schema.createTable('dlq_entries', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.string('source', 120).notNullable();
    table.text('reason').notNullable();
    table.jsonb('payload').notNullable();
    table.timestamp('created_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());
    table.timestamp('processed_at', { useTz: true });
  });

  for (const tableName of [
    'users',
    'profiles',
    'service_categories',
    'spa_services',
    'bookings',
  ]) {
    await knex.raw(`
      create trigger ${tableName}_set_updated_at
      before update on ${tableName}
      for each row
      execute function set_updated_at();
    `);
  }
};

exports.down = async function down(knex) {
  for (const tableName of [
    'bookings',
    'spa_services',
    'service_categories',
    'profiles',
    'users',
  ]) {
    await knex.raw(`drop trigger if exists ${tableName}_set_updated_at on ${tableName}`);
  }

  await knex.schema.dropTableIfExists('dlq_entries');
  await knex.schema.dropTableIfExists('booking_status_history');
  await knex.schema.dropTableIfExists('bookings');
  await knex.schema.dropTableIfExists('spa_services');
  await knex.schema.dropTableIfExists('service_categories');
  await knex.schema.dropTableIfExists('profiles');
  await knex.schema.dropTableIfExists('users');
  await knex.raw('drop function if exists set_updated_at');
};
