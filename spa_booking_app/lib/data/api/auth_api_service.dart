// Import ApiClient để gọi endpoint auth và UserProfile để parse user trả về.
import '../../core/network/api_client.dart';
import '../../models/user_profile.dart';

// Dữ liệu phiên đăng nhập gồm user và cặp access/refresh token.
class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final UserProfile user;
  final String accessToken;
  final String refreshToken;
}

// Service đóng gói các API liên quan đăng nhập và đăng ký.
class AuthApiService {
  AuthApiService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  // Gọi API đăng nhập bằng email/password và trả về AuthSession.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return _sessionFrom(data);
  }

  // Gọi API đăng ký tài khoản mới và trả về AuthSession.
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/auth/register',
      body: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
    return _sessionFrom(data);
  }

  // Parse payload auth chung để tránh lặp code ở login/register.
  AuthSession _sessionFrom(Map<String, dynamic> data) {
    return AuthSession(
      user: UserProfile.fromApiJson(
        data['user'] as Map<String, dynamic>? ?? const {},
      ),
      accessToken: data['accessToken']?.toString() ?? '',
      refreshToken: data['refreshToken']?.toString() ?? '',
    );
  }
}
