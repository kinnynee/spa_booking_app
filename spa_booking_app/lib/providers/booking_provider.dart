import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/api/booking_api_service.dart';
import '../models/appointment.dart';
import '../models/spa_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingApiService _apiService = BookingApiService();

  List<Appointment> _bookings = [];
  bool _isLoading = false;
  String? _error;
  int _currentTabIndex = 0;

  List<Appointment> get appointments => _bookings;
  List<Appointment> get upcomingAppointments => _bookings.where((a) => a.status == AppointmentStatus.pending || a.status == AppointmentStatus.confirmed).toList();
  List<Appointment> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentTabIndex => _currentTabIndex;

  void setCurrentTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // Fetch list of bookings from API
  Future<void> fetchMyBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await _apiService.fetchMyBookings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a booking with the current API contract and update local state.
  Future<bool> createBooking({
    required SpaService service,
    required DateTime date,
    required String time,
    required String customerName,
    required String phone,
    required String note,
  }) async {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final appointmentTime = DateTime(date.year, date.month, date.day, hour, minute);

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newBooking = await _apiService.createBooking(
        service: service,
        appointmentTime: appointmentTime,
        customerName: customerName,
        phone: phone,
        note: note,
      );
      _bookings.insert(0, newBooking);
      return true;
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _apiService.cancelBooking(bookingId);
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(status: AppointmentStatus.cancelled);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

String formatMoney(int amount) {
  return '${NumberFormat('#,###', 'vi_VN').format(amount).replaceAll(',', '.')}\u0111';
}

String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

String statusText(AppointmentStatus status) {
  switch (status) {
    case AppointmentStatus.pending:
      return 'Chờ xác nhận';
    case AppointmentStatus.confirmed:
      return 'Đã xác nhận';
    case AppointmentStatus.completed:
      return 'Đã hoàn thành';
    case AppointmentStatus.cancelled:
      return 'Đã hủy';
  }
}
