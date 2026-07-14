import 'package:flutter/foundation.dart';

import '../admin/models/admin_category.dart';
import '../data/api/admin_category_api_service.dart';

class AdminCategoryProvider extends ChangeNotifier {
  AdminCategoryProvider({AdminCategoryApiService? apiService})
    : _apiService = apiService ?? AdminCategoryApiService();

  final AdminCategoryApiService _apiService;
  final List<AdminCategory> _categories = [];

  bool _isLoading = false;
  bool _isSaving = false;
  bool _loaded = false;
  String? _errorMessage;

  List<AdminCategory> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasLoaded => _loaded;
  String? get errorMessage => _errorMessage;

  Future<void> loadCategories({bool refresh = false}) async {
    if (_isLoading || (_loaded && !refresh)) {
      return;
    }

    _setLoading(true);
    try {
      final categories = await _apiService.fetchCategories();
      _categories
        ..clear()
        ..addAll(categories);
      _loaded = true;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = _messageFrom(
        error,
        'Kh\u00f4ng th\u1ec3 t\u1ea3i danh m\u1ee5c.',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createCategory({
    required String name,
    required String slug,
    required String description,
    required int sortOrder,
    required bool isActive,
  }) async {
    _setSaving(true);
    try {
      final category = await _apiService.createCategory(
        name: name,
        slug: slug,
        description: description,
        sortOrder: sortOrder,
        isActive: isActive,
      );
      _categories.add(category);
      _sortCategories();
      _errorMessage = null;
      _loaded = true;
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(
        error,
        'Kh\u00f4ng th\u1ec3 th\u00eam danh m\u1ee5c.',
      );
      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> updateCategory(
    AdminCategory category, {
    required String name,
    required String slug,
    required String description,
    required int sortOrder,
    required bool isActive,
  }) async {
    _setSaving(true);
    try {
      final updated = await _apiService.updateCategory(
        category.id,
        name: name,
        slug: slug,
        description: description,
        sortOrder: sortOrder,
        isActive: isActive,
      );
      _replace(updated);
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(
        error,
        'Kh\u00f4ng th\u1ec3 c\u1eadp nh\u1eadt danh m\u1ee5c.',
      );
      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> archiveCategory(AdminCategory category) async {
    _setSaving(true);
    try {
      final updated = await _apiService.updateCategory(
        category.id,
        isActive: false,
      );
      _replace(updated);
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(
        error,
        'Kh\u00f4ng th\u1ec3 \u1ea9n danh m\u1ee5c.',
      );
      return false;
    } finally {
      _setSaving(false);
    }
  }

  void _replace(AdminCategory category) {
    final index = _categories.indexWhere((item) => item.id == category.id);
    if (index == -1) {
      _categories.add(category);
    } else {
      _categories[index] = category;
    }
    _sortCategories();
  }

  void _sortCategories() {
    _categories.sort((a, b) {
      final sortCompare = a.sortOrder.compareTo(b.sortOrder);
      if (sortCompare != 0) {
        return sortCompare;
      }
      return a.name.compareTo(b.name);
    });
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  String _messageFrom(Object error, String fallback) {
    final message = error.toString().trim();
    return message.isEmpty ? fallback : message;
  }
}
