import '../../admin/models/admin_mock_data.dart';
import '../../core/network/api_client.dart';

class AdminBookingApiService {
  AdminBookingApiService({ApiClient? client})
    : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<AdminBooking>> fetchBookings({
    AdminBookingStatus? status,
    AdminPaymentStatus? paymentStatus,
    String? search,
  }) async {
    final data = await _client.get<List<dynamic>>(
      '/bookings',
      query: {
        'status': status?.apiValue,
        'paymentStatus': paymentStatus?.apiValue,
        'search': search,
      },
    );

    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminBooking.fromJson)
        .toList();
  }

  Future<List<AdminCustomer>> fetchCustomers() async {
    final data = await _client.get<List<dynamic>>('/users', query: {'limit': '100'});

    return data
        .whereType<Map<String, dynamic>>()
        .where((user) => user['role']?.toString() == 'customer')
        .where((user) => user['isActive'] != false && user['is_active'] != false)
        .map(AdminCustomer.fromJson)
        .where((customer) => customer.id.isNotEmpty)
        .toList();
  }

  Future<List<AdminService>> fetchServices() async {
    final data = await _client.get<List<dynamic>>('/services');

    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminService.fromJson)
        .where((service) => service.id.isNotEmpty && service.isActive)
        .toList();
  }

  Future<AdminBooking> createBooking({
    required String customerId,
    required String serviceId,
    required DateTime appointmentTime,
    String? note,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/bookings/admin',
      body: {
        'customerId': customerId,
        'serviceId': serviceId,
        'appointmentTime': appointmentTime.toUtc().toIso8601String(),
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );

    return AdminBooking.fromJson(data);
  }

  Future<AdminBooking> updateBookingStatus(
    String id,
    AdminBookingStatus status, {
    String? reason,
  }) async {
    final data = await _client.patch<Map<String, dynamic>>(
      '/bookings/$id/status',
      body: {
        'status': status.apiValue,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );

    return AdminBooking.fromJson(data);
  }

  Future<AdminBooking> updatePaymentStatus(
    String id,
    AdminPaymentStatus paymentStatus,
  ) async {
    final data = await _client.patch<Map<String, dynamic>>(
      '/bookings/$id/payment-status',
      body: {'paymentStatus': paymentStatus.apiValue},
    );

    return AdminBooking.fromJson(data);
  }
}
