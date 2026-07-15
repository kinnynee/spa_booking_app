// Import model lịch hẹn và dịch vụ mẫu để tạo dữ liệu demo.
import '../models/appointment.dart';
import 'mock_services.dart';

// Tạo danh sách lịch hẹn mẫu tương đối theo ngày hiện tại.
List<Appointment> createMockAppointments() {
  final today = DateTime.now();

  return [
    Appointment(
      id: 'sample-1',
      service: mockServices.first,
      date: today.add(const Duration(days: 1)),
      time: '10:00',
      customerName: 'Tran Trung Kien',
      phone: '0901 234 567',
      note: 'Uu tien phong yen tinh',
      status: AppointmentStatus.pending,
    ),
    Appointment(
      id: 'sample-2',
      service: mockServices[1],
      date: today.subtract(const Duration(days: 2)),
      time: '15:00',
      customerName: 'Tran Trung Kien',
      phone: '0901 234 567',
      note: '',
      status: AppointmentStatus.completed,
    ),
  ];
}
