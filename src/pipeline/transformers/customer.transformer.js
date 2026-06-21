function transformCustomer(record) {
  return {
    fullName: String(record.fullName || record.name || '').trim(),
    email: String(record.email || '')
      .trim()
      .toLowerCase(),
    phone: record.phone ? String(record.phone).trim() : null,
    birthDate: record.birthDate || null,
  };
}

module.exports = {
  transformCustomer,
};
