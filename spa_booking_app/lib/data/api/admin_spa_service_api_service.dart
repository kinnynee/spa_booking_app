import 'dart:typed_data';

import '../../admin/models/admin_spa_service.dart';
import '../../core/network/api_client.dart';

class AdminSpaServiceApiService {
  AdminSpaServiceApiService({ApiClient? client})
    : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<AdminSpaService>> fetchServices({
    String? search,
    String? status,
  }) async {
    final data = await _client.get<List<dynamic>>(
      '/services/admin',
      query: {'search': search, 'status': status},
    );

    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminSpaService.fromJson)
        .toList();
  }

  Future<String> uploadServiceImage({
    required Uint8List bytes,
    required String contentType,
  }) async {
    final data = await _client.postBinary<Map<String, dynamic>>(
      '/services/admin/image',
      bytes: bytes,
      contentType: contentType,
    );
    final imageUrl = data['imageUrl']?.toString() ?? '';
    if (imageUrl.isEmpty) {
      throw const ApiException('Backend kh?ng tr? v? ???ng d?n ?nh.');
    }
    return imageUrl;
  }

  Future<AdminSpaService> createService({
    required String categoryId,
    required String name,
    required int price,
    required int durationMinutes,
    String description = '',
    String imageUrl = '',
    bool isActive = true,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/services/admin',
      body: _payload(
        categoryId: categoryId,
        name: name,
        price: price,
        durationMinutes: durationMinutes,
        description: description,
        imageUrl: imageUrl,
        isActive: isActive,
      ),
    );
    return AdminSpaService.fromJson(data);
  }

  Future<AdminSpaService> updateService(
    String id, {
    String? categoryId,
    String? name,
    int? price,
    int? durationMinutes,
    String? description,
    String? imageUrl,
    bool? isActive,
  }) async {
    final data = await _client.patch<Map<String, dynamic>>(
      '/services/admin/$id',
      body: _payload(
        categoryId: categoryId,
        name: name,
        price: price,
        durationMinutes: durationMinutes,
        description: description,
        imageUrl: imageUrl,
        isActive: isActive,
      ),
    );
    return AdminSpaService.fromJson(data);
  }

  Map<String, dynamic> _payload({
    String? categoryId,
    String? name,
    int? price,
    int? durationMinutes,
    String? description,
    String? imageUrl,
    bool? isActive,
  }) {
    final payload = <String, dynamic>{};
    if (categoryId != null) payload['categoryId'] = categoryId;
    if (name != null) payload['name'] = name.trim();
    if (price != null) payload['price'] = price;
    if (durationMinutes != null) payload['durationMinutes'] = durationMinutes;
    if (description != null) {
      payload['description'] = description.trim().isEmpty
          ? null
          : description.trim();
    }
    if (imageUrl != null) {
      payload['imageUrl'] = imageUrl.trim().isEmpty ? null : imageUrl.trim();
    }
    if (isActive != null) payload['isActive'] = isActive;
    return payload;
  }
}
