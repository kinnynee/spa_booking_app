import 'package:flutter/foundation.dart';

import '../admin/models/admin_mock_data.dart';
import '../data/api/admin_booking_api_service.dart';

class AdminBookingProvider extends ChangeNotifier {
  AdminBookingProvider({AdminBookingApiService? apiService})
    : _apiService = apiService ?? AdminBookingApiService();

  final AdminBookingApiService _apiService;
  final List<AdminBooking> _bookings = [];
  final Set<String> _updatingIds = {};
  final List<AdminCustomer> _customers = [];
  final List<AdminService> _services = [];

  bool _isLoading = false;
  bool _loaded = false;
  bool _isLoadingFormOptions = false;
  bool _isCreating = false;
  bool _formOptionsLoaded = false;
  String? _errorMessage;
  int _loadRequestId = 0;

  List<AdminBooking> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;
  bool get hasLoaded => _loaded;
  List<AdminCustomer> get customers => List.unmodifiable(_customers);
  List<AdminService> get services => List.unmodifiable(_services);
  bool get isLoadingFormOptions => _isLoadingFormOptions;
  bool get isCreating => _isCreating;

  String? get errorMessage => _errorMessage;

  bool isUpdating(String id) => _updatingIds.contains(id);

  AdminBooking? bookingById(String id) {
    for (final booking in _bookings) {
      if (booking.id == id) {
        return booking;
      }
    }
    return null;
  }

  Future<void> loadBookings({bool refresh = false}) async {
    if (_isLoading || (_loaded && !refresh)) {
      return;
    }

    final requestId = ++_loadRequestId;
    _setLoading(true);
    try {
      final bookings = await _apiService.fetchBookings();
      if (requestId != _loadRequestId) {
        return;
      }
      _bookings
        ..clear()
        ..addAll(bookings);
      _errorMessage = null;
      _loaded = true;
    } catch (error) {
      if (requestId != _loadRequestId) {
        return;
      }
      _errorMessage = _messageFrom(
        error,
        'Kh\u00f4ng th\u1ec3 t\u1ea3i danh s\u00e1ch l\u1ecbch h\u1eb9n.',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<AdminBooking?> confirmBooking(String id) {
    return updateBookingStatus(id, AdminBookingStatus.confirmed);
  }

  Future<void> loadBookingFormOptions({bool refresh = false}) async {
    if (_isLoadingFormOptions || (_formOptionsLoaded && !refresh)) {
      return;
    }

    _isLoadingFormOptions = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _apiService.fetchCustomers(),
        _apiService.fetchServices(),
      ]);
      _customers
        ..clear()
        ..addAll(results[0] as List<AdminCustomer>);
      _services
        ..clear()
        ..addAll(results[1] as List<AdminService>);
      _errorMessage = null;
      _formOptionsLoaded = true;
    } catch (error) {
      _errorMessage = _messageFrom(
        error,
        'Không thể tải khách hàng và dịch vụ.',
      );
    } finally {
      _isLoadingFormOptions = false;
      notifyListeners();
    }
  }

  Future<AdminBooking?> createBooking({
    required String customerId,
    required String serviceId,
    required DateTime appointmentTime,
    String? note,
  }) async {
    if (_isCreating) {
      return null;
    }

    _isCreating = true;
    notifyListeners();
    try {
      final booking = await _apiService.createBooking(
        customerId: customerId,
        serviceId: serviceId,
        appointmentTime: appointmentTime,
        note: note,
      );
      // Invalidate any list request started before the create call. Its
      // response may have been generated before this booking existed and
      // must not clear the newly created item from the local list.
      _loadRequestId++;
      _upsert(booking);
      _errorMessage = null;
      _loaded = true;
      return booking;
    } catch (error) {
      _errorMessage = _messageFrom(error, 'Không thể tạo lịch hẹn.');
      return null;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<AdminBooking?> cancelBooking(String id, {String? reason}) {
    return updateBookingStatus(
      id,
      AdminBookingStatus.cancelled,
      reason: reason,
    );
  }

  Future<AdminBooking?> completeBooking(String id) {
    return updateBookingStatus(id, AdminBookingStatus.completed);
  }

  Future<AdminBooking?> confirmPayment(String id) {
    return updatePaymentStatus(id, AdminPaymentStatus.paid);
  }

  Future<AdminBooking?> updateBookingStatus(
    String id,
    AdminBookingStatus status, {
    String? reason,
  }) async {
    if (_updatingIds.contains(id)) {
      return null;
    }

    _setUpdating(id, true);
    try {
      final booking = await _apiService.updateBookingStatus(
        id,
        status,
        reason: reason,
      );
      _upsert(booking);
      _errorMessage = null;
      return booking;
    } catch (error) {
      _errorMessage = _messageFrom(
        error,
        'Kh\u00f4ng th\u1ec3 c\u1eadp nh\u1eadt l\u1ecbch h\u1eb9n.',
      );
      return null;
    } finally {
      _setUpdating(id, false);
    }
  }

  Future<AdminBooking?> updatePaymentStatus(
    String id,
    AdminPaymentStatus paymentStatus,
  ) async {
    if (_updatingIds.contains(id)) {
      return null;
    }

    _setUpdating(id, true);
    try {
      final booking = await _apiService.updatePaymentStatus(id, paymentStatus);
      _upsert(booking);
      _errorMessage = null;
      return booking;
    } catch (error) {
      _errorMessage = _messageFrom(
        error,
        'Kh\u00f4ng th\u1ec3 c\u1eadp nh\u1eadt giao d\u1ecbch.',
      );
      return null;
    } finally {
      _setUpdating(id, false);
    }
  }

  void _upsert(AdminBooking booking) {
    final index = _bookings.indexWhere((item) => item.id == booking.id);
    if (index == -1) {
      _bookings.insert(0, booking);
    } else {
      _bookings[index] = booking;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setUpdating(String id, bool value) {
    if (value) {
      _updatingIds.add(id);
    } else {
      _updatingIds.remove(id);
    }
    notifyListeners();
  }

  String _messageFrom(Object error, String fallback) {
    final message = error.toString().trim();
    return message.isEmpty ? fallback : message;
  }
}
