
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = const FlutterSecureStorage();
  late final Dio _dio = _buildDio();

  Dio _buildDio() {
    final dio = Dio(BaseOptions(
      baseUrl: kApiBase,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            final refreshToken = await _storage.read(key: 'refresh_token');
            if (refreshToken == null) return handler.next(error);
            final res = await Dio().post('$kApiBase/auth/refresh',
                data: {'refreshToken': refreshToken});
            final newToken = res.data['accessToken'];
            await _storage.write(key: 'access_token', value: newToken);
            error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            return handler.resolve(await _dio.fetch(error.requestOptions));
          } catch (_) {
            await _storage.deleteAll();
          }
        }
        return handler.next(error);
      },
    ));
    return dio;
  }

  Dio get dio => _dio;

  Future<void> setTokens(String access, String refresh) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  Future<void> clearTokens() async => await _storage.deleteAll();

  Future<String?> getAccessToken() => _storage.read(key: 'access_token');
}
