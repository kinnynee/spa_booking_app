// Import ApiClient và model catalog để parse dữ liệu spa từ backend.
import '../../core/network/api_client.dart';
import '../../models/service_category.dart';
import '../../models/spa_service.dart';

// Service đóng gói API lấy danh mục và dịch vụ spa.
class SpaApiService {
  SpaApiService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  // Lấy danh sách danh mục và bỏ những item không có tên hiển thị.
  Future<List<ServiceCategory>> fetchCategories() async {
    final data = await _client.get<List<dynamic>>('/categories');
    return data
        .whereType<Map<String, dynamic>>()
        .map(ServiceCategory.fromJson)
        .where((category) => category.name.isNotEmpty)
        .toList();
  }

  // Lấy danh sách dịch vụ, có thể truyền search/categorySlug để backend lọc.
  Future<List<SpaService>> fetchServices({
    String? search,
    String? categorySlug,
  }) async {
    final data = await _client.get<List<dynamic>>(
      '/services',
      query: {'search': search, 'categorySlug': categorySlug},
    );

    return data
        .whereType<Map<String, dynamic>>()
        .map(SpaService.fromApiJson)
        .toList();
  }
}
