import '../../core/network/api_client.dart';
import '../../models/user_profile.dart';

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

class AuthApiService {
  AuthApiService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<AuthSession> login({
    required String account,
    required String password,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/auth/login',
      body: {'email': account, 'password': password},
    );
    return _sessionFrom(data);
  }

  Future<AuthSession> loginWithGoogle({required String idToken}) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/auth/google',
      body: {'idToken': idToken},
    );
    return _sessionFrom(data);
  }

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
