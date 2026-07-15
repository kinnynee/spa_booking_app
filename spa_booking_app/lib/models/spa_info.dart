// Class bất biến: mọi field đều final và được truyền qua constructor const.
class SpaInfo {
  const SpaInfo({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.openingHours,
    required this.description,
  });

  // Tên spa.
  final String name;
  // Địa chỉ spa.
  final String address;
  // Số điện thoại liên hệ.
  final String phone;
  // Email liên hệ.
  final String email;
  // Giờ mở cửa hiển thị trên card thông tin.
  final String openingHours;
  // Mô tả ngắn về spa.
  final String description;
}
