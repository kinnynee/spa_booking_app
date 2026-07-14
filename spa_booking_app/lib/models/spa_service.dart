import '../core/constants/app_assets.dart';

// Model này được dùng bởi mock_services.dart, ServiceCard, HomeScreen,
// ServicesScreen và ServiceDetailScreen.
// Class dữ liệu bất biến: các field final giúp thông tin dịch vụ không bị đổi tùy tiện.
class SpaService {
  const SpaService({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.image,
    required this.rating,
    required this.isPopular,
    required this.tag,
    required this.benefits,
    required this.process,
    this.slug,
    this.categorySlug,
  });

  // Mã định danh dịch vụ, dùng để phân biệt từng service.
  final String id;
  // Tên dịch vụ hiển thị trên card và chi tiết.
  final String name;
  // Nhóm dịch vụ, ví dụ Massage hoặc Chăm sóc da.
  final String category;
  // Mô tả ngắn về dịch vụ.
  final String description;
  // Giá dịch vụ, lưu dạng số nguyên để dễ format tiền.
  final int price;
  // Thời lượng dịch vụ tính bằng phút.
  final int durationMinutes;
  // Đường dẫn ảnh, hiện có thể là URL online từ AppAssets.
  final String image;
  // Điểm đánh giá dùng để hiển thị badge sao.
  final double rating;
  // true nếu dịch vụ được đưa vào danh sách nổi bật.
  final bool isPopular;
  // Nhãn nhỏ như Phổ biến, Mới, Combo; rỗng thì không hiện tag.
  final String tag;
  // Danh sách lợi ích hiển thị ở màn chi tiết.
  final List<String> benefits;
  // Danh sách bước quy trình hiển thị ở màn chi tiết.
  final List<String> process;
  // Slug của dịch vụ từ backend, dùng khi cần route hoặc gọi API chi tiết.
  final String? slug;
  // Slug danh mục từ backend, dùng để lọc dịch vụ theo API.
  final String? categorySlug;

  // Factory này chuyển JSON backend thành SpaService; vẫn giữ để sau này nối API thật.
  factory SpaService.fromApiJson(Map<String, dynamic> json) {
    final categoryJson = json['category'];
    final categoryName = categoryJson is Map<String, dynamic>
        ? categoryJson['name']?.toString()
        : json['category']?.toString();
    final categorySlug = categoryJson is Map<String, dynamic>
        ? categoryJson['slug']?.toString()
        : json['categorySlug']?.toString();
    final isPopular = json['isPopular'] == true || json['is_popular'] == true;

    return SpaService(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Dịch vụ spa',
      category: _displayCategory(categoryName ?? 'Dịch vụ'),
      description: json['description']?.toString() ?? '',
      price: _asInt(json['price']),
      durationMinutes: _asInt(
        json['durationMinutes'] ?? json['duration_minutes'],
      ),
      image: _resolveImage(json, categorySlug),
      rating: _asDouble(json['rating']) ?? (isPopular ? 4.8 : 4.6),
      isPopular: isPopular,
      tag: json['tag']?.toString() ?? (isPopular ? 'Phổ biến' : ''),
      benefits: _stringList(json['benefits']).ifEmpty(_defaultBenefits),
      process: _stringList(json['process']).ifEmpty(_defaultProcess),
      slug: json['slug']?.toString(),
      categorySlug: categorySlug,
    );
  }

  // Hàm phụ đổi dữ liệu bất kỳ sang int an toàn.
  static String _resolveImage(Map<String, dynamic> json, String? categorySlug) {
    final remote = json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? '';
    if (remote.trim().isNotEmpty) return remote;
    final slug = (categorySlug ?? '').toLowerCase();
    if (slug.contains('skin') || slug.contains('facial')) return AppAssets.facial;
    if (slug.contains('treatment') || slug.contains('massage')) return AppAssets.massage;
    if (slug.contains('nail')) return AppAssets.nail;
    if (slug.contains('hair')) return AppAssets.hairWash;
    if (slug.contains('wax')) return AppAssets.waxing;
    return AppAssets.massage;
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

  // Hàm phụ đổi dữ liệu bất kỳ sang double; trả null nếu không đổi được.
  static double? _asDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }

  // Hàm phụ chuẩn hóa List động thành List<String>.
  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  // Chuẩn hóa tên category tiếng Anh từ API sang tiếng Việt hiển thị.
  static String _displayCategory(String value) {
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

  static const List<String> _defaultBenefits = [
    'Thư giãn cơ thể',
    'Cải thiện năng lượng',
    'Chăm sóc bởi kỹ thuật viên',
  ];

  static const List<String> _defaultProcess = [
    'Tư vấn nhanh trước liệu trình',
    'Thực hiện dịch vụ theo tiêu chuẩn spa',
    'Nghỉ ngơi và dùng trà sau liệu trình',
  ];
}

// Extension thêm hàm ifEmpty cho List để dùng fallback ngắn gọn hơn.
extension _ListFallback<T> on List<T> {
  List<T> ifEmpty(List<T> fallback) => isEmpty ? fallback : this;
}
