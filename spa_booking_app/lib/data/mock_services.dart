// File này chứa danh mục, dữ liệu dịch vụ mẫu và hàm lọc dịch vụ.
// UI hiện lấy danh sách này thông qua CatalogProvider nên app có thể chạy không cần backend.
// Import asset ảnh và model SpaService để khai báo danh sách dịch vụ mẫu.
import '../core/constants/app_assets.dart';
import '../models/spa_service.dart';

// Tên category đặc biệt dùng để biểu thị trạng thái không lọc theo danh mục.
const String allServicesCategory = 'Tất cả';

// Danh sách category dùng để render các CategoryChip ở HomeScreen và ServicesScreen.
const List<String> serviceCategories = [
  'Tất cả',
  'Massage',
  'Chăm sóc da',
  'Gội đầu',
  'Trị liệu',
  'Dưỡng thể',
  'Nail',
  'Combo',
];

// Lợi ích mặc định dùng lại cho những service không cần viết riêng.
const List<String> defaultBenefits = [
  'Giảm căng thẳng',
  'Thư giãn cơ thể',
  'Cải thiện giấc ngủ',
];

// Quy trình mặc định dùng lại cho những service không cần viết riêng.
const List<String> defaultProcess = [
  'Tư vấn nhanh tình trạng cơ thể',
  'Xông tinh dầu và làm ấm vùng trị liệu',
  'Massage thư giãn theo liệu trình',
  'Nghỉ ngơi và dùng trà thảo mộc',
];

// Hàm lọc nhanh trên danh sách mockServices mặc định.
List<SpaService> filterServices({
  required String category,
  required String keyword,
}) {
  return filterServiceList(
    services: mockServices,
    category: category,
    keyword: keyword,
  );
}

// Hàm lọc tổng quát: nhận danh sách bất kỳ, category và keyword để trả về kết quả phù hợp.
List<SpaService> filterServiceList({
  required List<SpaService> services,
  required String category,
  required String keyword,
}) {
  // Chuẩn hóa keyword: bỏ khoảng trắng đầu/cuối và chuyển chữ thường để tìm không phân biệt hoa/thường.
  final normalizedKeyword = keyword.trim().toLowerCase();

  // where duyệt từng dịch vụ và chỉ giữ lại dịch vụ thỏa điều kiện.
  final filtered = services.where((service) {
    // matchesCategory đúng khi chọn 'Tất cả' hoặc category của service trùng category đang chọn.
    final matchesCategory =
        category == allServicesCategory || service.category == category;
    if (normalizedKeyword.isEmpty) {
      return matchesCategory;
    }

    // Service chỉ được hiển thị khi đồng thời khớp category và keyword.
    return matchesCategory && _matchScore(service, normalizedKeyword) < 3;
  }).toList();

  if (normalizedKeyword.isEmpty) {
    return filtered;
  }

  // Dịch vụ khớp tên/category được ưu tiên lên trước các dịch vụ chỉ khớp mô tả/quy trình.
  filtered.sort(
    (a, b) => _matchScore(
      a,
      normalizedKeyword,
    ).compareTo(_matchScore(b, normalizedKeyword)),
  );
  return filtered;
}

// Tính mức độ khớp keyword: 0 là khớp mạnh nhất, 3 là không khớp.
int _matchScore(SpaService service, String normalizedKeyword) {
  final primaryText = _searchText([service.name, service.category]);
  if (primaryText.contains(normalizedKeyword)) {
    return 0;
  }

  final secondaryText = _searchText([service.description, service.tag]);
  if (secondaryText.contains(normalizedKeyword)) {
    return 1;
  }

  final detailText = _searchText([...service.benefits, ...service.process]);
  if (detailText.contains(normalizedKeyword)) {
    return 2;
  }

  return 3;
}

// Ghép nhiều trường text thành một chuỗi chữ thường để so khớp keyword.
String _searchText(List<String> values) => values.join(' ').toLowerCase();

// Danh sách dịch vụ mẫu. Mỗi SpaService gồm id, tên, category, mô tả, giá, ảnh, rating, tag, lợi ích và quy trình.
const List<SpaService> mockServices = [
  SpaService(
    id: 'massage-body',
    name: 'Massage body thư giãn',
    category: 'Massage',
    description:
        'Liệu trình massage toàn thân với tinh dầu thiên nhiên giúp giảm đau mỏi, thả lỏng cơ và phục hồi năng lượng.',
    price: 350000,
    durationMinutes: 60,
    image: AppAssets.massage,
    rating: 4.8,
    isPopular: true,
    tag: 'Phổ biến',
    benefits: defaultBenefits,
    process: defaultProcess,
  ),
  SpaService(
    id: 'basic-facial',
    name: 'Chăm sóc da cơ bản',
    category: 'Chăm sóc da',
    description:
        'Làm sạch sâu, tẩy tế bào chết và cấp ẩm nhẹ nhàng cho làn da tươi sáng hơn.',
    price: 300000,
    durationMinutes: 45,
    image: AppAssets.facial,
    rating: 4.7,
    isPopular: true,
    tag: 'Phổ biến',
    benefits: ['Sạch sâu', 'Dưỡng ẩm', 'Da mềm mịn'],
    process: ['Tẩy trang', 'Làm sạch da', 'Đắp mặt nạ dưỡng ẩm'],
  ),
  SpaService(
    id: 'herbal-hair-wash',
    name: 'Gội đầu dưỡng sinh',
    category: 'Gội đầu',
    description:
        'Gội đầu thảo dược kết hợp massage đầu, cổ, vai gáy để giảm mệt mỏi sau ngày dài.',
    price: 180000,
    durationMinutes: 45,
    image: AppAssets.hairWash,
    rating: 4.9,
    isPopular: true,
    tag: 'Mới',
    benefits: ['Giảm đau đầu', 'Thư giãn vai gáy', 'Tóc mềm hơn'],
    process: ['Chải huyệt vùng đầu', 'Gội thảo dược', 'Massage cổ vai gáy'],
  ),
  SpaService(
    id: 'acne-care',
    name: 'Trị mụn chuyên sâu',
    category: 'Trị liệu',
    description:
        'Quy trình làm sạch, lấy nhân mụn chuẩn vệ sinh và làm dịu da bằng sản phẩm chuyên dụng.',
    price: 550000,
    durationMinutes: 90,
    image: AppAssets.acneCare,
    rating: 4.6,
    isPopular: false,
    tag: 'Khuyến mãi',
    benefits: ['Giảm viêm', 'Sạch lỗ chân lông', 'Hỗ trợ phục hồi da'],
    process: ['Soi da', 'Làm sạch và lấy nhân mụn', 'Đắp mặt nạ làm dịu'],
  ),
  SpaService(
    id: 'hot-stone',
    name: 'Massage đá nóng',
    category: 'Massage',
    description:
        'Kết hợp massage thư giãn và đá nóng để làm dịu vùng cơ căng cứng, cải thiện tuần hoàn.',
    price: 450000,
    durationMinutes: 75,
    image: AppAssets.hotStone,
    rating: 4.8,
    isPopular: true,
    tag: 'Best seller',
    benefits: ['Giảm đau mỏi', 'Lưu thông máu', 'Thư thái tinh thần'],
    process: ['Làm nóng cơ thể', 'Massage đá nóng', 'Thưởng trà thư giãn'],
  ),
  SpaService(
    id: 'deep-facial',
    name: 'Chăm sóc da chuyên sâu',
    category: 'Chăm sóc da',
    description:
        'Chăm sóc da chuyên sâu với tinh chất phục hồi, phù hợp làn da thiếu ẩm và mệt mỏi.',
    price: 500000,
    durationMinutes: 90,
    image: AppAssets.facial,
    rating: 4.8,
    isPopular: false,
    tag: 'Phục hồi',
    benefits: ['Cấp ẩm sâu', 'Da sáng khỏe', 'Giảm mệt mỏi cho da'],
    process: ['Làm sạch', 'Massage mặt', 'Ủ tinh chất phục hồi'],
  ),
  SpaService(
    id: 'body-scrub',
    name: 'Tẩy tế bào chết toàn thân',
    category: 'Dưỡng thể',
    description:
        'Sử dụng muối khoáng và dầu dưỡng để làm sạch lớp da chết, giúp da mềm và đều màu hơn.',
    price: 420000,
    durationMinutes: 70,
    image: AppAssets.bodyScrub,
    rating: 4.7,
    isPopular: false,
    tag: 'Da sáng',
    benefits: ['Da mịn hơn', 'Hỗ trợ đều màu da', 'Thư giãn nhẹ nhàng'],
    process: ['Làm sạch da', 'Tẩy tế bào chết', 'Ủ dưỡng thể'],
  ),
  SpaService(
    id: 'aroma-therapy',
    name: 'Trị liệu hương thơm',
    category: 'Trị liệu',
    description:
        'Liệu trình kết hợp tinh dầu lavender, nhạc thiền và massage nhịp chậm để cân bằng tinh thần.',
    price: 480000,
    durationMinutes: 75,
    image: AppAssets.aromatherapy,
    rating: 4.9,
    isPopular: true,
    tag: 'Thư giãn sâu',
    benefits: ['Dễ ngủ hơn', 'Giảm căng thẳng', 'Tinh thần nhẹ nhàng'],
    process: ['Chọn tinh dầu', 'Xông hương', 'Massage nhịp chậm'],
  ),
  SpaService(
    id: 'gel-nail',
    name: 'Nail gel dưỡng móng',
    category: 'Nail',
    description:
        'Cắt da, tạo dáng móng, phủ gel bền màu và dưỡng móng theo phong cách thanh lịch.',
    price: 220000,
    durationMinutes: 50,
    image: AppAssets.nail,
    rating: 4.6,
    isPopular: false,
    tag: 'Nhanh gọn',
    benefits: ['Móng gọn đẹp', 'Màu bền', 'Dưỡng móng nhẹ'],
    process: ['Làm sạch móng', 'Tạo form', 'Sơn gel và dưỡng móng'],
  ),
  SpaService(
    id: 'waxing-smooth',
    name: 'Waxing dịu nhẹ',
    category: 'Dưỡng thể',
    description:
        'Waxing bằng sản phẩm dịu nhẹ, có bước làm dịu và dưỡng ẩm sau liệu trình.',
    price: 260000,
    durationMinutes: 40,
    image: AppAssets.waxing,
    rating: 4.5,
    isPopular: false,
    tag: '',
    benefits: ['Da sạch mịn', 'Ít kích ứng', 'Dưỡng ẩm sau wax'],
    process: ['Làm sạch vùng da', 'Waxing', 'Làm dịu và dưỡng ẩm'],
  ),
  SpaService(
    id: 'couple-relax',
    name: 'Combo thư giãn đôi',
    category: 'Combo',
    description:
        'Gói chăm sóc dành cho hai người gồm massage body, ngâm chân thảo mộc và trà thư giãn.',
    price: 820000,
    durationMinutes: 100,
    image: AppAssets.coupleSpa,
    rating: 4.9,
    isPopular: true,
    tag: 'Combo',
    benefits: ['Tiết kiệm hơn', 'Không gian riêng', 'Trải nghiệm trọn vẹn'],
    process: ['Ngâm chân', 'Massage body', 'Dùng trà sau liệu trình'],
  ),
];
