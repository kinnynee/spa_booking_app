// foundation cung cấp ChangeNotifier cho state lịch hẹn.
import 'package:flutter/foundation.dart';
// intl dùng để format tiền và ngày theo locale Việt Nam.
import 'package:intl/intl.dart';

// Import API service và model dùng khi tải/tạo/hủy lịch.
import '../data/api/booking_api_service.dart';
import '../models/appointment.dart';
import '../models/spa_service.dart';

// Provider quản lý danh sách lịch hẹn và tab đang chọn ở bottom navigation.
class BookingProvider extends ChangeNotifier {
  BookingProvider({BookingApiService? apiService})
    : _apiService = apiService ?? BookingApiService();

  final BookingApiService _apiService;
  final List<Appointment> _appointments = [];

  int _currentTabIndex = 0;
  bool _isLoading = false;
  bool _loaded = false;
  String? _errorMessage;
  int _loadRequestId = 0;

  // Getter trả bản read-only để màn hình không sửa trực tiếp list private.
  List<Appointment> get appointments => List.unmodifiable(_appointments);
  int get currentTabIndex => _currentTabIndex;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _loaded;
  String? get errorMessage => _errorMessage;

  // Đổi tab hiện tại của MainShell và thông báo UI rebuild.
  void setCurrentTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // Tải danh sách lịch hẹn từ backend; refresh=true cho phép tải lại thủ công.
  Future<void> loadAppointments({bool refresh = false}) async {
    if (_isLoading || (_loaded && !refresh)) {
      return;
    }

    final requestId = ++_loadRequestId;
    _setLoading(true);
    try {
      final bookings = await _apiService.fetchMyBookings();
      if (requestId != _loadRequestId) {
        return;
      }
      _appointments
        ..clear()
        ..addAll(bookings);
      _errorMessage = null;
      _loaded = true;
    } catch (error) {
      if (requestId != _loadRequestId) {
        return;
      }
      _errorMessage = _messageFrom(error, 'Không thể tải lịch hẹn.');
    } finally {
      _setLoading(false);
    }
  }

  // Tạo lịch hẹn mới qua backend và đưa kết quả lên đầu danh sách local.
  Future<bool> addAppointment({
    required SpaService service,
    required DateTime date,
    required String time,
    required String customerName,
    required String phone,
    required String note,
  }) async {
    _setLoading(true);
    try {
      final appointment = await _apiService.createBooking(
        service: service,
        appointmentTime: _combineDateAndTime(date, time),
        note: note,
        customerName: customerName,
        phone: phone,
      );
      // Do not let an older in-flight list request clear this new item.
      _loadRequestId++;
      _appointments.insert(0, appointment);
      _errorMessage = null;
      _loaded = true;
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(error, 'Không thể đặt lịch.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Hủy lịch trên backend, sau đó cập nhật lại trạng thái local để UI phản hồi ngay.
  Future<bool> cancelAppointment(String id) async {
    final index = _appointments.indexWhere(
      (appointment) => appointment.id == id,
    );
    if (index == -1) {
      _errorMessage = 'Không tìm thấy lịch hẹn cần hủy.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      await _apiService.cancelBooking(id);
      _appointments[index] = _appointments[index].copyWith(
        status: AppointmentStatus.cancelled,
      );
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(error, 'Không thể hủy lịch hẹn.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Ghép ngày và chuỗi HH:mm từ form thành DateTime local trước khi gửi backend.
  DateTime _combineDateAndTime(DateTime date, String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  // Đổi trạng thái loading và thông báo cho các màn hình đang watch provider.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Chuẩn hóa exception thành message thân thiện cho SnackBar/empty state.
  String _messageFrom(Object error, String fallback) {
    final message = error.toString().trim();
    return message.isEmpty ? fallback : message;
  }
}

// Format số tiền sang dạng 350.000đ cho giao diện tiếng Việt.
String formatMoney(int amount) {
  return '${NumberFormat('#,###', 'vi_VN').format(amount).replaceAll(',', '.')}đ';
}

// Format ngày sang dd/MM/yyyy để hiển thị trong lịch hẹn và summary.
String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

// Đổi enum trạng thái lịch hẹn thành nhãn tiếng Việt cho UI.
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
