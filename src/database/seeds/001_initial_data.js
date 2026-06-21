const { hashPassword } = require('../../common/utils/password');

exports.seed = async function seed(knex) {
  await knex.transaction(async (trx) => {
    await trx('booking_status_history').del();
    await trx('bookings').del();
    await trx('spa_services').del();
    await trx('service_categories').del();
    await trx('profiles').del();
    await trx('users').del();

    const [admin] = await trx('users')
      .insert({
        full_name: 'System Admin',
        email: 'admin@spa.local',
        phone: '0900000000',
        password_hash: await hashPassword('Admin@12345'),
        role: 'admin',
      })
      .returning('*');

    await trx('profiles').insert({
      user_id: admin.id,
    });

    const categories = await trx('service_categories')
      .insert([
        {
          name: 'Massage',
          slug: 'massage',
          description: 'Relaxing body massage services.',
          sort_order: 1,
        },
        {
          name: 'Skin Care',
          slug: 'skin-care',
          description: 'Facial and skin care treatments.',
          sort_order: 2,
        },
        {
          name: 'Treatment',
          slug: 'treatment',
          description: 'Specialized spa treatment packages.',
          sort_order: 3,
        },
      ])
      .returning('*');

    const categoryBySlug = Object.fromEntries(categories.map((category) => [category.slug, category]));

    await trx('spa_services').insert([
      {
        category_id: categoryBySlug.massage.id,
        name: 'Aroma Relax Massage',
        slug: 'aroma-relax-massage',
        description: 'A gentle aromatherapy massage for stress relief.',
        price: 450000,
        duration_minutes: 60,
        is_popular: true,
      },
      {
        category_id: categoryBySlug['skin-care'].id,
        name: 'Hydrating Facial Care',
        slug: 'hydrating-facial-care',
        description: 'Deep hydration facial care for bright and soft skin.',
        price: 520000,
        duration_minutes: 75,
        is_popular: true,
      },
      {
        category_id: categoryBySlug.treatment.id,
        name: 'Hot Stone Therapy',
        slug: 'hot-stone-therapy',
        description: 'Warm stone therapy for muscle relaxation.',
        price: 650000,
        duration_minutes: 90,
        is_popular: false,
      },
    ]);
  });
};
