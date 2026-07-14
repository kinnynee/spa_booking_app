// Người 2 - mock_spa_data
// File này chứa dữ liệu mẫu về spa để trang chủ hiển thị thông tin cửa hàng.
// Dữ liệu được khai báo const vì không thay đổi trong lúc chạy app.
// Import model SpaInfo để khai báo thông tin cửa hàng đúng cấu trúc.
import '../models/spa_info.dart';

// Đối tượng thông tin spa chính được dùng trong HomeScreen._SpaInfoCard.
const SpaInfo lavenderSpa = SpaInfo(
  name: 'Lavender Spa',
  address: '123 Nguyễn Trãi, Quận 1, TP.HCM',
  phone: '0901 234 567',
  email: 'lavenderspa@gmail.com',
  openingHours: '08:00 - 21:00',
  description:
      'Không gian chăm sóc sức khỏe và sắc đẹp theo phong cách hiện đại, kết hợp liệu trình thư giãn, trị liệu cơ bản và dịch vụ làm đẹp nhanh trong ngày.',
);
