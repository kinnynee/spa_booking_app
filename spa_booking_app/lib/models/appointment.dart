// Import SpaService vì mỗi lịch hẹn luôn gắn với một dịch vụ cụ thể.
import 'spa_service.dart';

// Các trạng thái chính của lịch hẹn trong app.
enum AppointmentStatus { pending, confirmed, completed, cancelled }

// Model dữ liệu cho một lịch hẹn của khách hàng.
class Appointment {
  const Appointment({
    required this.id,
    required this.service,
    required this.date,
    required this.time,
    required this.customerName,
    required this.phone,
    required this.note,
    required this.status,
  });

  final String id;
  final SpaService service;
  final DateTime date;
  final String time;
  final String customerName;
  final String phone;
  final String note;
  final AppointmentStatus status;

  // Chuyển JSON từ backend booking thành Appointment dùng trong UI.
  factory Appointment.fromBookingJson(
    Map<String, dynamic> json, {
    SpaService? fallbackService,
    String customerName = '',
    String phone = '',
  }) {
    final appointmentTime =
        DateTime.tryParse(
          json['appointmentTime']?.toString() ??
              json['appointment_time']?.toString() ??
              '',
        )?.toLocal() ??
        DateTime.now();
    final service =
        fallbackService ??
        SpaService(
          id:
              json['serviceId']?.toString() ??
              json['service_id']?.toString() ??
              '',
          name:
              json['serviceName']?.toString() ??
              json['service_name']?.toString() ??
              'Dịch vụ spa',
          category: 'Dịch vụ',
          description: '',
          price: _asInt(json['totalPrice'] ?? json['total_price']),
          durationMinutes: _asInt(
            json['serviceDurationMinutes'] ?? json['service_duration_minutes'],
          ),
          image: '',
          rating: 4.8,
          isPopular: false,
          tag: '',
          benefits: const [],
          process: const [],
        );

    return Appointment(
      id: json['id']?.toString() ?? '',
      service: service,
      date: DateTime(
        appointmentTime.year,
        appointmentTime.month,
        appointmentTime.day,
      ),
      time:
          '${appointmentTime.hour.toString().padLeft(2, '0')}:${appointmentTime.minute.toString().padLeft(2, '0')}',
      customerName: customerName,
      phone: phone,
      note: json['note']?.toString() ?? '',
      status: _statusFrom(json['status']?.toString()),
    );
  }

  // Tạo bản sao lịch hẹn với status mới, dùng khi hủy hoặc cập nhật trạng thái.
  Appointment copyWith({AppointmentStatus? status}) {
    return Appointment(
      id: id,
      service: service,
      date: date,
      time: time,
      customerName: customerName,
      phone: phone,
      note: note,
      status: status ?? this.status,
    );
  }

  // Chuẩn hóa chuỗi status từ API sang enum nội bộ.
  static AppointmentStatus _statusFrom(String? value) {
    switch (value) {
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }

  // Ép dữ liệu số từ API về int an toàn, fallback 0 nếu không hợp lệ.
  static int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
