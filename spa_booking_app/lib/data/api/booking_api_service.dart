// Import ApiClient và các model cần thiết cho luồng booking.
import '../../core/network/api_client.dart';
import '../../models/appointment.dart';
import '../../models/spa_service.dart';

// Service đóng gói API lấy, tạo và hủy lịch hẹn.
class BookingApiService {
  BookingApiService({ApiClient? client})
    : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  // Lấy danh sách booking của user hiện tại từ backend.
  Future<List<Appointment>> fetchMyBookings() async {
    final data = await _client.get<List<dynamic>>('/bookings/me');
    return data
        .whereType<Map<String, dynamic>>()
        .map(Appointment.fromBookingJson)
        .toList();
  }

  // Tạo booking mới, gửi thời gian dạng UTC ISO để backend xử lý nhất quán.
  Future<Appointment> createBooking({
    required SpaService service,
    required DateTime appointmentTime,
    required String note,
    required String customerName,
    required String phone,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/bookings',
      body: {
        'serviceId': service.id,
        'appointmentTime': appointmentTime.toUtc().toIso8601String(),
        if (note.trim().isNotEmpty) 'note': note.trim(),
      },
    );

    return Appointment.fromBookingJson(
      data,
      fallbackService: service,
      customerName: customerName,
      phone: phone,
    );
  }

  // Gửi yêu cầu hủy booking; reason chỉ gửi khi người dùng nhập nội dung.
  Future<Appointment> cancelBooking(String id, {String? reason}) async {
    final data = await _client.patch<Map<String, dynamic>>(
      '/bookings/$id/cancel',
      body: {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return Appointment.fromBookingJson(data);
  }
}
