class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.birthday,
    required this.gender,
    required this.avatar,
  });

  final String fullName;
  final String email;
  final String phone;
  final String birthday;
  final String gender;
  final String avatar;

  factory UserProfile.fromApiJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    final profileMap = profile is Map<String, dynamic>
        ? profile
        : const <String, dynamic>{};

    return UserProfile(
      fullName:
          json['fullName']?.toString() ??
          json['full_name']?.toString() ??
          'Khách hàng',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      birthday:
          profileMap['birthDate']?.toString() ??
          profileMap['birth_date']?.toString() ??
          'Chưa cập nhật',
      gender: _genderLabel(profileMap['gender']?.toString()),
      avatar:
          profileMap['avatarUrl']?.toString() ??
          profileMap['avatar_url']?.toString() ??
          '',
    );
  }

  static String _genderLabel(String? value) {
    switch (value) {
      case 'male':
        return 'Nam';
      case 'female':
        return 'Nữ';
      case 'other':
        return 'Khác';
      default:
        return 'Chưa cập nhật';
    }
  }
}
