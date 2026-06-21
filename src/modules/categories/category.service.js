const cache = require('../../common/cache/cache.service');
const categoryRepository = require('./category.repository');

const CACHE_KEY = 'service-categories:active';

async function listCategories() {
  const cached = await cache.getJson(CACHE_KEY);

  if (cached) {
    return cached;
  }

  const categories = await categoryRepository.listActive();
  await cache.setJson(CACHE_KEY, categories);

  return categories;
}

module.exports = {
  listCategories,
};
