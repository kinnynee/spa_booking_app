function toUserDto(user) {
  if (!user) {
    return null;
  }

  return {
    id: user.id,
    fullName: user.full_name || user.fullName,
    email: user.email,
    phone: user.phone,
    role: user.role,
    isActive: user.is_active ?? user.isActive,
    profile: user.profile,
    createdAt: user.created_at || user.createdAt,
  };
}

module.exports = {
  toUserDto,
};
