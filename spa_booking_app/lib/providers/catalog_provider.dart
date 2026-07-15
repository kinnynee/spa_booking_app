// foundation cung cấp ChangeNotifier để màn hình lắng nghe thay đổi catalog.
import 'package:flutter/foundation.dart';

// Import API service, dữ liệu mock cho test và các model catalog.
import '../data/api/spa_api_service.dart';
import '../data/mock_services.dart';
import '../models/service_category.dart';
import '../models/spa_service.dart';

// Provider quản lý danh mục và danh sách dịch vụ spa.
class CatalogProvider extends ChangeNotifier {
  CatalogProvider({SpaApiService? apiService, bool seedMockData = false})
    : _apiService = apiService ?? SpaApiService(),
      _categories = seedMockData ? _mockCategories : const [],
      _services = seedMockData ? mockServices : const [],
      _loaded = seedMockData;

  final SpaApiService _apiService;
  List<ServiceCategory> _categories;
  List<SpaService> _services;
  bool _isLoading = false;
  bool _loaded;
  String? _errorMessage;

  // Getter trả dữ liệu read-only để UI không sửa list private trực tiếp.
  List<ServiceCategory> get categories => List.unmodifiable(_categories);
  List<String> get categoryNames => _categories
      .map((category) => category.name)
      .where((name) => name.trim().isNotEmpty)
      .toList(growable: false);
  List<SpaService> get services => List.unmodifiable(_services);
  bool get isLoading => _isLoading;
  bool get hasLoaded => _loaded;
  String? get errorMessage => _errorMessage;

  // Nạp catalog từ backend một lần; refresh=true cho phép người dùng thử lại.
  Future<void> loadCatalog({bool refresh = false}) async {
    if (_isLoading || (_loaded && !refresh)) {
      return;
    }

    _setLoading(true);
    try {
      final categories = await _apiService.fetchCategories();
      final services = await _apiService.fetchServices();
      _categories = _withAllCategory(categories);
      _services = services;
      _errorMessage = null;
      _loaded = true;
    } catch (error) {
      _errorMessage = _messageFrom(error, 'Không thể tải danh sách dịch vụ.');
    } finally {
      _setLoading(false);
    }
  }

  // Lọc dịch vụ hiện có theo danh mục và từ khóa tìm kiếm.
  List<SpaService> filterServices({
    required String category,
    required String keyword,
  }) {
    return filterServiceList(
      services: _services,
      category: category,
      keyword: keyword,
    );
  }

  // Đổi trạng thái loading và thông báo cho các màn hình đang watch provider.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Luôn thêm category 'Tất cả' ở đầu danh sách để UI có trạng thái không lọc.
  List<ServiceCategory> _withAllCategory(List<ServiceCategory> categories) {
    final withoutAll = categories
        .where((category) => category.name != allServicesCategory)
        .toList(growable: false);
    return [const ServiceCategory(name: allServicesCategory), ...withoutAll];
  }

  // Chuẩn hóa exception thành message thân thiện cho màn hình lỗi.
  String _messageFrom(Object error, String fallback) {
    final message = error.toString().trim();
    return message.isEmpty ? fallback : message;
  }
}

// Chuyển danh sách tên category mock thành model ServiceCategory.
final List<ServiceCategory> _mockCategories = serviceCategories
    .map((name) => ServiceCategory(name: name))
    .toList(growable: false);
