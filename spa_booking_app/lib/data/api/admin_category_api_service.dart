import '../../admin/models/admin_category.dart';
import '../../core/network/api_client.dart';

class AdminCategoryApiService {
  AdminCategoryApiService({ApiClient? client})
    : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<AdminCategory>> fetchCategories({
    String? search,
    String? status,
  }) async {
    final data = await _client.get<List<dynamic>>(
      '/categories/admin',
      query: {'search': search, 'status': status},
    );

    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminCategory.fromJson)
        .toList();
  }

  Future<AdminCategory> createCategory({
    required String name,
    required String slug,
    required String description,
    required int sortOrder,
    required bool isActive,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/categories/admin',
      body: _payload(
        name: name,
        slug: slug,
        description: description,
        sortOrder: sortOrder,
        isActive: isActive,
      ),
    );
    return AdminCategory.fromJson(data);
  }

  Future<AdminCategory> updateCategory(
    String id, {
    String? name,
    String? slug,
    String? description,
    int? sortOrder,
    bool? isActive,
  }) async {
    final data = await _client.patch<Map<String, dynamic>>(
      '/categories/admin/$id',
      body: _payload(
        name: name,
        slug: slug,
        description: description,
        sortOrder: sortOrder,
        isActive: isActive,
      ),
    );
    return AdminCategory.fromJson(data);
  }

  Map<String, dynamic> _payload({
    String? name,
    String? slug,
    String? description,
    int? sortOrder,
    bool? isActive,
  }) {
    final payload = <String, dynamic>{};
    if (name != null) {
      payload['name'] = name.trim();
    }
    if (slug != null && slug.trim().isNotEmpty) {
      payload['slug'] = slug.trim();
    }
    if (description != null) {
      payload['description'] = description.trim();
    }
    if (sortOrder != null) {
      payload['sortOrder'] = sortOrder;
    }
    if (isActive != null) {
      payload['isActive'] = isActive;
    }
    return payload;
  }
}
