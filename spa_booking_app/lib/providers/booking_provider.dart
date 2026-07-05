import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../data/api/booking_api_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingApiService _apiService = BookingApiService();

  List<Appointment> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<Appointment> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
}
