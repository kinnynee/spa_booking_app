// Model đại diện cho một danh mục dịch vụ spa.
class ServiceCategory {
  const ServiceCategory({required this.name, this.slug});

  final String name;
  final String? slug;

  // Chuyển JSON category từ API sang model hiển thị trong app.
  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      name: _displayName(json['name']?.toString() ?? ''),
      slug: json['slug']?.toString(),
    );
  }

  // Đổi một số tên category tiếng Anh từ backend sang tiếng Việt.
  static String _displayName(String value) {
    switch (value.toLowerCase()) {
      case 'massage':
        return 'Mát-xa';
      case 'skin care':
        return 'Chăm sóc da';
      case 'treatment':
        return 'Trị liệu';
      default:
        return value;
    }
  }
}
