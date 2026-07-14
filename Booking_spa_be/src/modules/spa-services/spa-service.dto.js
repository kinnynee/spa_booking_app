function toSpaServiceDto(service) {
  if (!service) {
    return null;
  }

  return {
    id: service.id,
    name: service.name,
    slug: service.slug,
    description: service.description,
    price: Number(service.price),
    durationMinutes: service.duration_minutes,
    imageUrl: service.image_url,
    isPopular: service.is_popular,
    isActive: service.is_active,
    category: service.category_name
      ? {
          id: service.category_id,
          name: service.category_name,
          slug: service.category_slug,
        }
      : undefined,
  };
}

module.exports = {
  toSpaServiceDto,
};
