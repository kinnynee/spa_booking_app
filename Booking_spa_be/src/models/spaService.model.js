const ServiceCategories = Object.freeze({
  MASSAGE: 'massage',
  SKINCARE: 'skincare',
  TREATMENT: 'treatment',
  RELAXATION: 'relaxation',
});

function buildSpaServiceModel(payload) {
  return {
    name: payload.name,
    category: payload.category,
    description: payload.description || '',
    price: payload.price,
    durationMinutes: payload.durationMinutes,
    imageUrl: payload.imageUrl || '',
    isPopular: Boolean(payload.isPopular),
    isActive: payload.isActive ?? true,
  };
}

module.exports = {
  ServiceCategories,
  buildSpaServiceModel,
};
