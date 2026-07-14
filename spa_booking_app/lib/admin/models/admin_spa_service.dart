class AdminSpaService {
  const AdminSpaService({
    required this.id,
    required this.name,
    required this.slug,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    required this.durationMinutes,
    required this.isActive,
    this.description = '',
    this.imageUrl = '',
    this.isPopular = false,
  });

  final String id;
  final String name;
  final String slug;
  final String categoryId;
  final String categoryName;
  final int price;
  final int durationMinutes;
  final String description;
  final String imageUrl;
  final bool isPopular;
  final bool isActive;

  factory AdminSpaService.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];
    final category = rawCategory is Map<String, dynamic> ? rawCategory : null;

    return AdminSpaService(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      categoryId: category?['id']?.toString() ?? '',
      categoryName: category?['name']?.toString() ?? 'Chưa phân loại',
      price: _asInt(json['price']),
      durationMinutes: _asInt(
        json['durationMinutes'] ?? json['duration_minutes'],
      ),
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? '',
      isPopular: _asBool(json['isPopular'] ?? json['is_popular']),
      isActive: _asBool(json['isActive'] ?? json['is_active'], fallback: true),
    );
  }

  AdminSpaService copyWith({
    String? name,
    String? slug,
    String? categoryId,
    String? categoryName,
    int? price,
    int? durationMinutes,
    String? description,
    String? imageUrl,
    bool? isPopular,
    bool? isActive,
  }) {
    return AdminSpaService(
      id: id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isPopular: isPopular ?? this.isPopular,
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
    return num.tryParse(value?.toString() ?? '')?.round() ?? 0;
  }

  static bool _asBool(Object? value, {bool fallback = false}) {
    if (value is bool) {
      return value;
    }
    return value?.toString().toLowerCase() == 'true' ? true : fallback;
  }
}
