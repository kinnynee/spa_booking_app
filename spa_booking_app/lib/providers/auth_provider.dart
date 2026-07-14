// foundation cung cấp ChangeNotifier để phát tín hiệu rebuild cho UI.
import 'dart:async';

import 'package:flutter/foundation.dart';

// Import ApiClient để lưu token và AuthApiService để gọi backend thật.
import '../core/network/api_client.dart';
import '../data/auth/google_auth_service.dart';
import '../data/api/auth_api_service.dart';
import '../data/mock_user.dart';
import '../models/user_profile.dart';

// Provider quản lý trạng thái đăng nhập, user hiện tại và token phiên làm việc.
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthApiService? apiService,
    GoogleAuthService? googleAuthService,
  }) : _apiService = apiService ?? AuthApiService(),
       _googleAuthService = googleAuthService ?? GoogleAuthService() {
    unawaited(_listenForWebGoogleSignIn());
  }

  final AuthApiService _apiService;
  final GoogleAuthService _googleAuthService;
  StreamSubscription<String>? _webGoogleTokenSubscription;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  UserProfile _currentUser = mockUser;
  String? _accessToken;
  String? _refreshToken;

  // Các getter chỉ đọc giúp UI lấy state mà không sửa trực tiếp biến private.
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserProfile get currentUser => _currentUser;
  bool get isAdmin => _isAuthenticated && _currentUser.isAdmin;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  // Đăng nhập qua backend, luôn tắt loading trong finally để UI không bị kẹt.
  Future<bool> login({
    required String account,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final session = await _apiService.login(
        account: account.trim(),
        password: password,
      );
      _applySession(session);
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(error, 'Đăng nhập thất bại.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Đăng ký tài khoản mới qua backend và tự đăng nhập bằng session trả về.
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final session = await _apiService.register(
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        password: password,
      );
      _applySession(session);
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(error, 'Đăng ký thất bại.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Xóa lỗi hiện tại để form có thể ẩn thông báo cũ.
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    try {
      final idToken = await _googleAuthService.signInInteractively();
      final session = await _apiService.loginWithGoogle(idToken: idToken);
      _applySession(session);
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(error, 'Google sign-in failed.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clears the current authentication error.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Đăng xuất bằng cách xóa trạng thái xác thực và token.
  void logout() {
    _isAuthenticated = false;
    _accessToken = null;
    _refreshToken = null;
    ApiClient.instance.setAccessToken(null);
    unawaited(_googleAuthService.signOut());
    notifyListeners();
  }

  // Gán user/token thật từ backend rồi lưu access token cho các API tiếp theo.
  Future<void> _listenForWebGoogleSignIn() async {
    try {
      await _googleAuthService.initialize();
      _webGoogleTokenSubscription = _googleAuthService.webIdTokens.listen(
        _loginWithGoogleIdToken,
        onError: (Object error, StackTrace stackTrace) {
          if (_isLoading) {
            return;
          }
          _errorMessage = _messageFrom(error, 'Google sign-in failed.');
          notifyListeners();
        },
      );
    } catch (_) {
      // The button action displays the configuration error when relevant.
    }
  }

  Future<void> _loginWithGoogleIdToken(String idToken) async {
    if (_isLoading) {
      return;
    }

    _setLoading(true);
    try {
      final session = await _apiService.loginWithGoogle(idToken: idToken);
      _applySession(session);
    } catch (error) {
      _errorMessage = _messageFrom(error, 'Google sign-in failed.');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String birthDate,
    required String gender,
    required String address,
    required String avatarUrl,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _apiService.updateProfile(
        fullName: fullName.trim(),
        phone: phone.trim(),
        birthDate: birthDate,
        gender: gender,
        address: address.trim(),
        avatarUrl: avatarUrl.trim(),
      );
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(error, 'Could not update profile.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _applySession(AuthSession session) {
    _currentUser = session.user;
    _accessToken = session.accessToken;
    _refreshToken = session.refreshToken;
    _isAuthenticated = session.accessToken.isNotEmpty;
    _errorMessage = null;
    ApiClient.instance.setAccessToken(session.accessToken);
    notifyListeners();
  }

  // Cập nhật trạng thái loading và dọn lỗi cũ khi bắt đầu request mới.
  void _setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  // Chuẩn hóa exception thành message thân thiện cho SnackBar/form.
  String _messageFrom(Object error, String fallback) {
    final message = error.toString().trim();
    return message.isEmpty ? fallback : message;
  }

  @override
  void dispose() {
    _webGoogleTokenSubscription?.cancel();
    _googleAuthService.dispose();
    super.dispose();
  }
}
