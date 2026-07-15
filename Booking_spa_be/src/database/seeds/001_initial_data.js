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
        full_name: 'Trần Trung Kiên',
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
          name: 'Mát-xa',
          slug: 'massage',
          description: 'Dịch vụ mát-xa thư giãn toàn thân.',
          sort_order: 1,
        },
        {
          name: 'Chăm sóc da',
          slug: 'skin-care',
          description: 'Liệu trình chăm sóc da mặt và phục hồi làn da.',
          sort_order: 2,
        },
        {
          name: 'Trị liệu',
          slug: 'treatment',
          description: 'Các gói trị liệu spa chuyên sâu.',
          sort_order: 3,
        },
      ])
      .returning('*');

    const categoryBySlug = Object.fromEntries(
      categories.map((category) => [category.slug, category]),
    );

    await trx('spa_services').insert([
      {
        category_id: categoryBySlug.massage.id,
        name: 'Mát-xa hương thơm thư giãn',
        slug: 'aroma-relax-massage',
        description: 'Liệu trình mát-xa hương thơm nhẹ nhàng giúp giảm căng thẳng.',
        price: 450000,
        duration_minutes: 60,
        is_popular: true,
      },
      {
        category_id: categoryBySlug['skin-care'].id,
        name: 'Chăm sóc da cấp ẩm',
        slug: 'hydrating-facial-care',
        description: 'Chăm sóc da chuyên sâu giúp cấp ẩm, làm sáng và mềm da.',
        price: 520000,
        duration_minutes: 75,
        is_popular: true,
      },
      {
        category_id: categoryBySlug.treatment.id,
        name: 'Trị liệu đá nóng',
        slug: 'hot-stone-therapy',
        description: 'Trị liệu đá nóng giúp thư giãn cơ và giảm nhức mỏi.',
        price: 650000,
        duration_minutes: 90,
        is_popular: false,
      },
    ]);
  });
};
