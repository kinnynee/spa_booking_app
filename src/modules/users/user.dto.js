function asNumber(value) {
  const number = Number(value);
  return Number.isFinite(number) ? number : 0;
}

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
    totalBookings: asNumber(user.total_bookings ?? user.totalBookings),
    totalSpent: asNumber(user.total_spent ?? user.totalSpent),
  };
}

module.exports = {
  toUserDto,
};
