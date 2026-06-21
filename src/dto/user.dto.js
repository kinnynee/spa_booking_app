function toUserDto(user) {
  if (!user) return null;

  return {
    uid: user.uid || user.id,
    email: user.email,
    displayName: user.displayName || '',
    phoneNumber: user.phoneNumber || '',
    photoURL: user.photoURL || '',
    dateOfBirth: user.dateOfBirth || null,
    gender: user.gender || '',
    role: user.role || 'customer',
    isActive: user.isActive ?? true,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  };
}

module.exports = {
  toUserDto,
};
