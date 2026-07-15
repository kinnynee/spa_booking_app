const services = [
  {
    id: 'aroma-relax-massage',
    category: 'massage',
    categoryName: 'Massage',
    name: 'Aroma Relax Massage',
    description: 'A gentle aromatherapy massage for stress relief.',
    price: 450000,
    durationMinutes: 60,
    imageUrl: '/static/services/aroma-relax-massage.jpg',
    isPopular: true,
    isActive: true,
  },
  {
    id: 'hydrating-facial-care',
    category: 'skin-care',
    categoryName: 'Skin Care',
    name: 'Hydrating Facial Care',
    description: 'Deep hydration facial care for bright and soft skin.',
    price: 520000,
    durationMinutes: 75,
    imageUrl: '/static/services/hydrating-facial-care.jpg',
    isPopular: true,
    isActive: true,
  },
  {
    id: 'hot-stone-therapy',
    category: 'treatment',
    categoryName: 'Treatment',
    name: 'Hot Stone Therapy',
    description: 'Warm stone therapy for muscle relaxation.',
    price: 650000,
    durationMinutes: 90,
    imageUrl: '/static/services/hot-stone-therapy.jpg',
    isPopular: false,
    isActive: true,
  },
];

const categories = [
  {
    id: 'massage',
    name: 'Massage',
    description: 'Relaxing body massage services.',
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'skin-care',
    name: 'Skin Care',
    description: 'Facial and skin care treatments.',
    sortOrder: 2,
    isActive: true,
  },
  {
    id: 'treatment',
    name: 'Treatment',
    description: 'Specialized spa treatment packages.',
    sortOrder: 3,
    isActive: true,
  },
];

const demoUser = {
  id: 'demo-customer',
  fullName: 'Demo Customer',
  email: 'customer@spa.local',
  phone: '0900000001',
  role: 'customer',
  isActive: true,
};

module.exports = {
  categories,
  demoUser,
  services,
};
