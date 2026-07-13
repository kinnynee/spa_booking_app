import 'package:flutter/foundation.dart';

import '../data/mock_user.dart';
import '../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  UserProfile _currentUser = mockUser;
  String? _accessToken;
  String? _refreshToken;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserProfile get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  Future<bool> login({
    required String account,
    required String password,
  }) async {
    _setLoading(true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _applyMockSession(mockUser);
    _setLoading(false);
    return true;
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _applyMockSession(
      UserProfile(
        fullName: fullName,
        email: email,
        phone: phone,
        birthday: mockUser.birthday,
        gender: mockUser.gender,
        avatar: mockUser.avatar,
      ),
    );
    _setLoading(false);
    return true;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }

  void _applyMockSession(UserProfile user) {
    _currentUser = user;
    _accessToken = 'mock-access-token';
    _refreshToken = 'mock-refresh-token';
    _isAuthenticated = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _errorMessage = null;
    }
    notifyListeners();
  }
}
