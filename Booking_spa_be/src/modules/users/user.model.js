const userModel = Object.freeze({
  tableName: 'users',
  columns: {
    id: 'id',
    fullName: 'full_name',
    email: 'email',
    phone: 'phone',
    passwordHash: 'password_hash',
    role: 'role',
    isActive: 'is_active',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  },
});

module.exports = userModel;
