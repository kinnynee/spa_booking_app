import 'package:flutter/foundation.dart';

import '../admin/models/admin_spa_service.dart';
import '../data/api/admin_spa_service_api_service.dart';

class AdminSpaServiceProvider extends ChangeNotifier {
  AdminSpaServiceProvider({AdminSpaServiceApiService? apiService})
    : _apiService = apiService ?? AdminSpaServiceApiService();

  final AdminSpaServiceApiService _apiService;
  final List<AdminSpaService> _services = [];

  bool _isLoading = false;
  bool _isSaving = false;
  bool _loaded = false;
  String? _errorMessage;

  List<AdminSpaService> get services => List.unmodifiable(_services);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasLoaded => _loaded;
  String? get errorMessage => _errorMessage;

  Future<void> loadServices({bool refresh = false}) async {
    if (_isLoading || (_loaded && !refresh)) return;

    _isLoading = true;
    notifyListeners();
    try {
      final services = await _apiService.fetchServices();
      _services
        ..clear()
        ..addAll(services);
      _sortServices();
      _loaded = true;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = _messageFrom(error, 'Không thể tải dịch vụ.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadImage({
    required Uint8List bytes,
    required String contentType,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      final imageUrl = await _apiService.uploadServiceImage(
        bytes: bytes,
        contentType: contentType,
      );
      _errorMessage = null;
      return imageUrl;
    } catch (error) {
      _errorMessage = _messageFrom(error, 'Không thể tải ảnh lên.');
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> createService({
    required String categoryId,
    required String name,
    required int price,
    required int durationMinutes,
    String description = '',
    String imageUrl = '',
    bool isActive = true,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      final service = await _apiService.createService(
        categoryId: categoryId,
        name: name,
        price: price,
        durationMinutes: durationMinutes,
        description: description,
        imageUrl: imageUrl,
        isActive: isActive,
      );
      _services.add(service);
      _sortServices();
      _loaded = true;
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(error, 'Không thể thêm dịch vụ.');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateService(
    AdminSpaService current, {
    String? categoryId,
    String? name,
    int? price,
    int? durationMinutes,
    String? description,
    String? imageUrl,
    bool? isActive,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      final service = await _apiService.updateService(
        current.id,
        categoryId: categoryId,
        name: name,
        price: price,
        durationMinutes: durationMinutes,
        description: description,
        imageUrl: imageUrl,
        isActive: isActive,
      );
      final index = _services.indexWhere((item) => item.id == service.id);
      if (index == -1) {
        _services.add(service);
      } else {
        _services[index] = service;
      }
      _sortServices();
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(error, 'Không thể cập nhật dịch vụ.');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _sortServices() {
    _services.sort((a, b) => a.name.compareTo(b.name));
  }

  String _messageFrom(Object error, String fallback) {
    final message = error.toString().trim();
    return message.isEmpty ? fallback : message;
  }
}