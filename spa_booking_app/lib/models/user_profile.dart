class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.birthday,
    required this.gender,
    required this.genderCode,
    required this.address,
    required this.avatar,
    this.role = 'customer',
  });

  final String fullName;
  final String email;
  final String phone;
  final String birthday;
  final String gender;
  final String genderCode;
  final String address;
  final String avatar;
  final String role;

  bool get isAdmin => role.toLowerCase() == 'admin';
  String get displayBirthday =>
      birthday.isEmpty ? '\u0043h\u01b0a c\u1eadp nh\u1eadt' : birthday;
  String get displayGender =>
      genderCode.isEmpty ? '\u0043h\u01b0a c\u1eadp nh\u1eadt' : gender;
  String get displayAddress =>
      address.isEmpty ? '\u0043h\u01b0a c\u1eadp nh\u1eadt' : address;

  factory UserProfile.fromApiJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    final profileMap = profile is Map<String, dynamic>
        ? profile
        : const <String, dynamic>{};
    final genderCode = profileMap['gender']?.toString() ?? '';
    final birthDate =
        profileMap['birthDate']?.toString() ??
        profileMap['birth_date']?.toString() ??
        '';

    return UserProfile(
      fullName:
          json['fullName']?.toString() ??
          json['full_name']?.toString() ??
          '\u004b\u0068\u00e1ch h\u00e0ng',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      birthday: birthDate.length >= 10 ? birthDate.substring(0, 10) : birthDate,
      gender: _genderLabel(genderCode),
      genderCode: genderCode,
      address: profileMap['address']?.toString() ?? '',
      avatar:
          profileMap['avatarUrl']?.toString() ??
          profileMap['avatar_url']?.toString() ??
          '',
      role: json['role']?.toString() ?? 'customer',
    );
  }

  static String _genderLabel(String value) {
    switch (value) {
      case 'male':
        return '\u004e\u0061\u006d';
      case 'female':
        return '\u004e\u1eef';
      case 'other':
        return 'Kh\u00e1c';
      default:
        return '';
    }
  }
}
