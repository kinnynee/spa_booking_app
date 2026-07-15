// dart:async dùng TimeoutException và timeout cho request.
import 'dart:async';
// dart:convert dùng để encode/decode JSON khi gọi API.
import 'dart:convert';

// foundation giúp nhận biết nền tảng web/android để chọn baseUrl phù hợp.
import 'package:flutter/foundation.dart';
// Package http thực hiện các request GET/POST/PUT/PATCH.
import 'package:http/http.dart' as http;

// Exception riêng cho tầng API, kèm statusCode khi backend trả lỗi HTTP.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

// Client HTTP dùng chung, chịu trách nhiệm build URL, gắn token và parse response.
class ApiClient {
  ApiClient._();

  // Singleton giúp các service dùng cùng một client và cùng access token.
  static final ApiClient instance = ApiClient._();

  final http.Client _http = http.Client();
  String? _accessToken;

  // Chọn base URL theo biến môi trường hoặc nền tảng đang chạy.
  String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) {
      return override;
    }

    if (kIsWeb) {
      return 'http://localhost:3001/api/v1';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3001/api/v1';
    }

    return 'http://localhost:3001/api/v1';
  }

  // Kiểm tra client đã có access token để gắn Authorization header chưa.
  bool get hasToken => _accessToken != null && _accessToken!.isNotEmpty;

  // Lưu token đăng nhập để các request sau tự gửi kèm Bearer token.
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  // Gửi request GET và trả dữ liệu đã parse về kiểu T.
  Future<T> get<T>(String path, {Map<String, String?> query = const {}}) {
    return _request<T>('GET', path, query: query);
  }

  // Gửi request POST với body JSON.
  Future<T> post<T>(String path, {Map<String, dynamic>? body}) {
    return _request<T>('POST', path, body: body);
  }

  Future<T> postBinary<T>(
    String path, {
    required List<int> bytes,
    required String contentType,
  }) async {
    final uri = _uri(path, const {});
    final request = http.Request('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': contentType,
      if (hasToken) 'Authorization': 'Bearer $_accessToken',
    });
    request.bodyBytes = bytes;

    late http.Response response;
    try {
      final streamed = await _http.send(request);
      response = await http.Response.fromStream(streamed)
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const ApiException(
        'Kh?ng th? t?i ?nh l?n. Vui l?ng th? l?i.',
      );
    } catch (_) {
      throw const ApiException(
        'Kh?ng th? t?i ?nh l?n. Vui l?ng ki?m tra API server.',
      );
    }

    final decoded = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode >= 500) {
        throw ApiException(
          'M?y ch? g?p l?i khi t?i ?nh l?n.',
          statusCode: response.statusCode,
        );
      }
      throw ApiException(
        _messageFrom(decoded) ?? 'Kh?ng th? t?i ?nh l?n.',
        statusCode: response.statusCode,
      );
    }

    if (decoded is Map<String, dynamic>) {
      if (decoded['success'] == false) {
        throw ApiException(_messageFrom(decoded) ?? 'Kh?ng th? t?i ?nh l?n.');
      }
      return decoded['data'] as T;
    }
    return decoded as T;
  }

  // Gửi request PUT với body JSON.
  Future<T> put<T>(String path, {Map<String, dynamic>? body}) {
    return _request<T>('PUT', path, body: body);
  }

  // Gửi request PATCH với body JSON.
  Future<T> patch<T>(String path, {Map<String, dynamic>? body}) {
    return _request<T>('PATCH', path, body: body);
  }

  // Hàm xử lý chung: tạo URI/header, gửi request, bắt lỗi và bóc data.
  Future<T> _request<T>(
    String method,
    String path, {
    Map<String, String?> query = const {},
    Map<String, dynamic>? body,
  }) async {
    final uri = _uri(path, query);
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (hasToken) 'Authorization': 'Bearer $_accessToken',
    };

    late http.Response response;
    try {
      response = await _send(
        method,
        uri,
        headers,
        body,
      ).timeout(const Duration(seconds: 8));
    } on TimeoutException {
      throw const ApiException(
        'Không thể kết nối backend. Vui lòng kiểm tra API server.',
      );
    } catch (_) {
      throw const ApiException(
        'Không thể kết nối backend. Vui lòng kiểm tra API server.',
      );
    }

    final decoded = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 404) {
        throw ApiException(
          'Đường dẫn API không tồn tại: $method $uri',
          statusCode: response.statusCode,
        );
      }
      if (response.statusCode >= 500) {
        throw ApiException(
          'Backend đang gặp lỗi. Vui lòng kiểm tra API server và database.',
          statusCode: response.statusCode,
        );
      }
      throw ApiException(
        _messageFrom(decoded) ?? 'Yêu cầu thất bại.',
        statusCode: response.statusCode,
      );
    }

    if (decoded is Map<String, dynamic>) {
      if (decoded['success'] == false) {
        throw ApiException(_messageFrom(decoded) ?? 'Yêu cầu thất bại.');
      }
      return decoded['data'] as T;
    }

    return decoded as T;
  }

  // Chọn đúng hàm của package http theo method truyền vào.
  Future<http.Response> _send(
    String method,
    Uri uri,
    Map<String, String> headers,
    Map<String, dynamic>? body,
  ) {
    final encodedBody = body == null ? null : jsonEncode(body);

    switch (method) {
      case 'GET':
        return _http.get(uri, headers: headers);
      case 'POST':
        return _http.post(uri, headers: headers, body: encodedBody);
      case 'PUT':
        return _http.put(uri, headers: headers, body: encodedBody);
      case 'PATCH':
        return _http.patch(uri, headers: headers, body: encodedBody);
      default:
        throw ApiException('HTTP method không được hỗ trợ: $method');
    }
  }

  // Ghép baseUrl, path và query; tự bỏ query rỗng để URL gọn hơn.
  Uri _uri(String path, Map<String, String?> query) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final queryParameters = <String, String>{};
    for (final entry in query.entries) {
      final value = entry.value;
      if (value != null && value.trim().isNotEmpty) {
        queryParameters[entry.key] = value;
      }
    }

    return Uri.parse('$baseUrl$normalizedPath').replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
  }

  // Decode chuỗi JSON từ backend; response rỗng thì trả null.
  Object? _decode(String body) {
    if (body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      throw const ApiException('Backend trả về dữ liệu không hợp lệ.');
    }
  }

  // Lấy message/error từ response lỗi để hiển thị thân thiện hơn.
  String? _messageFrom(Object? decoded) {
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final message = decoded['message'] ?? decoded['error'];
    return message?.toString();
  }
}
