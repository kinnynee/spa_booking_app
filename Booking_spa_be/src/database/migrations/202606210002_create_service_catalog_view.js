exports.up = async function up(knex) {
  await knex.raw(`
    create or replace view service_catalog_view as
    select
      services.id,
      services.name,
      services.slug,
      services.description,
      services.price,
      services.duration_minutes,
      services.image_url,
      services.is_popular,
      categories.id as category_id,
      categories.name as category_name,
      categories.slug as category_slug
    from spa_services services
    join service_categories categories on categories.id = services.category_id
    where services.is_active = true
      and categories.is_active = true;
  `);
};

exports.down = async function down(knex) {
  await knex.raw('drop view if exists service_catalog_view');
};
