
import 'api_client.dart';

class AuthApi {
  final _client = ApiClient();

  Future<Map<String,dynamic>> register(String email,String password,String fullName) async {
    final res = await _client.dio.post('/auth/register',data:{'email':email,'password':password,'fullName':fullName});
    return res.data;
  }

  Future<Map<String,dynamic>> login(String email,String password) async {
    final res = await _client.dio.post('/auth/login',data:{'email':email,'password':password});
    return res.data;
  }

  Future<void> logout() async {
    try { await _client.dio.post('/auth/logout'); } catch (_) {}
  }

  Future<Map<String,dynamic>> me() async {
    final res = await _client.dio.get('/auth/me');
    return res.data;
  }
}
