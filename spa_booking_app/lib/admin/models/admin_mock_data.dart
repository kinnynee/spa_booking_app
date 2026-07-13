import 'package:intl/intl.dart';

// ─────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────

enum AdminBookingStatus { pending, confirmed, completed, cancelled }

class AdminBooking {
  const AdminBooking({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.serviceName,
    required this.dateTime,
    required this.price,
    required this.status,
    this.note = '',
    this.room = '',
  });

  final String id;
  final String customerName;
  final String phone;
  final String serviceName;
  final DateTime dateTime;
  final int price;
  final AdminBookingStatus status;
  final String note;
  final String room;
}

class AdminCustomer {
  const AdminCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.totalBookings,
    required this.totalSpent,
    required this.tag,
    this.avatarUrl = '',
  });

  final String id;
  final String name;
  final String phone;
  final int totalBookings;
  final int totalSpent;
  final String tag; // 'VIP', 'Mới', 'Thân thiết'
  final String avatarUrl;
}

class AdminService {
  const AdminService({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.durationMinutes,
    required this.description,
    required this.isActive,
    this.imageUrl = '',
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final int durationMinutes;
  final String description;
  final bool isActive;
  final String imageUrl;
}

// ─────────────────────────────────────────────
// Mock Data
// ─────────────────────────────────────────────

final List<AdminBooking> mockAdminBookings = [
  AdminBooking(
    id: 'SP001',
    customerName: 'Nguyễn Minh Anh',
    phone: '090 123 4567',
    serviceName: 'Massage thư giãn (Body)',
    dateTime: DateTime(2023, 10, 15, 10, 0),
    price: 450000,
    status: AdminBookingStatus.completed,
    note: 'Tôi muốn massage nhẹ vùng vai gáy',
    room: 'Phòng 02',
  ),
  AdminBooking(
    id: 'SP002',
    customerName: 'Trần Thị Bích Ngọc',
    phone: '091 888 9999',
    serviceName: 'Chăm sóc da mặt chuyên sâu',
    dateTime: DateTime(2023, 10, 16, 14, 30),
    price: 720000,
    status: AdminBookingStatus.pending,
    room: 'Phòng 01',
  ),
  AdminBooking(
    id: 'SP003',
    customerName: 'Lê Văn Hùng',
    phone: '098 765 4321',
    serviceName: 'Massage chân thảo dược',
    dateTime: DateTime(2023, 10, 17, 9, 15),
    price: 380000,
    status: AdminBookingStatus.confirmed,
    room: 'Phòng 04',
  ),
  AdminBooking(
    id: 'SP004',
    customerName: 'Phạm Thị Lan',
    phone: '097 111 2222',
    serviceName: 'Gội đầu dưỡng sinh',
    dateTime: DateTime(2023, 10, 18, 11, 0),
    price: 250000,
    status: AdminBookingStatus.pending,
    room: 'Phòng 03',
  ),
  AdminBooking(
    id: 'SP005',
    customerName: 'Võ Minh Tuấn',
    phone: '093 444 5555',
    serviceName: 'Massage đá nóng',
    dateTime: DateTime(2023, 10, 18, 15, 0),
    price: 850000,
    status: AdminBookingStatus.confirmed,
    room: 'Phòng 05',
  ),
];

final List<AdminCustomer> mockAdminCustomers = [
  const AdminCustomer(
    id: 'C001',
    name: 'Trần Thanh Hà',
    phone: '0912 345 678',
    totalBookings: 12,
    totalSpent: 5800000,
    tag: 'VIP',
    avatarUrl: 'https://i.pravatar.cc/150?img=47',
  ),
  const AdminCustomer(
    id: 'C002',
    name: 'Nguyễn Minh Anh',
    phone: '0988 776 554',
    totalBookings: 2,
    totalSpent: 1200000,
    tag: 'Mới',
    avatarUrl: 'https://i.pravatar.cc/150?img=48',
  ),
  const AdminCustomer(
    id: 'C003',
    name: 'Lê Thị Mai',
    phone: '0345 123 999',
    totalBookings: 28,
    totalSpent: 12400000,
    tag: 'Thân thiết',
    avatarUrl: 'https://i.pravatar.cc/150?img=49',
  ),
];

final List<AdminService> mockAdminServices = [
  const AdminService(
    id: 'SV001',
    name: 'Massage thư giãn',
    category: 'Massage',
    price: 450000,
    durationMinutes: 60,
    description: 'Liệu pháp massage toàn thân kết hợp tinh dầu Lavender giúp giảm căng thẳng.',
    isActive: true,
    imageUrl: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=400',
  ),
  const AdminService(
    id: 'SV002',
    name: 'Chăm sóc da mặt',
    category: 'Facial',
    price: 550000,
    durationMinutes: 75,
    description: 'Liệu trình làm sạch sâu, cấp ẩm và trẻ hóa làn da với sản phẩm cao cấp.',
    isActive: true,
    imageUrl: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400',
  ),
  const AdminService(
    id: 'SV003',
    name: 'Gội đầu dưỡng sinh',
    category: 'Tóc',
    price: 250000,
    durationMinutes: 45,
    description: 'Gội đầu bằng thảo mộc kết hợp massage ấn huyệt vùng đầu, cổ, vai.',
    isActive: false,
    imageUrl: 'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?w=400',
  ),
];

// ─────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────

String formatAdminMoney(int amount) {
  final formatted = NumberFormat('#,###', 'vi_VN').format(amount).replaceAll(',', '.');
  return '${formatted}đ';
}

String formatAdminDate(DateTime dt) => DateFormat('dd/MM/yyyy').format(dt);
String formatAdminTime(DateTime dt) => DateFormat('HH:mm').format(dt);
String formatAdminDateTime(DateTime dt) => '${formatAdminTime(dt)} - ${formatAdminDate(dt)}';
