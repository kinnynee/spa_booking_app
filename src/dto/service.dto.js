function toServiceDto(service) {
  if (!service) return null;

  return {
    id: service.id,
    name: service.name,
    category: service.category,
    description: service.description || '',
    price: service.price,
    durationMinutes: service.durationMinutes,
    imageUrl: service.imageUrl || '',
    isPopular: Boolean(service.isPopular),
    isActive: service.isActive ?? true,
    createdAt: service.createdAt,
    updatedAt: service.updatedAt,
  };
}

module.exports = {
  toServiceDto,
};
