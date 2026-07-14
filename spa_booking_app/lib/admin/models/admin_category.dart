class AdminCategory {
  const AdminCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.sortOrder,
    required this.isActive,
    this.description = '',
  });

  final String id;
  final String name;
  final String slug;
  final String description;
  final int sortOrder;
  final bool isActive;

  factory AdminCategory.fromJson(Map<String, dynamic> json) {
    return AdminCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      sortOrder: _asInt(json['sortOrder'] ?? json['sort_order']),
      isActive: json['isActive'] == true || json['is_active'] == true,
    );
  }

  AdminCategory copyWith({
    String? name,
    String? slug,
    String? description,
    int? sortOrder,
    bool? isActive,
  }) {
    return AdminCategory(
      id: id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  static int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
