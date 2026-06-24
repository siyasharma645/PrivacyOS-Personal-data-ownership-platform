
import 'api_client.dart';

class AccountsApi {
  final _client = ApiClient();
  Future<List<dynamic>> list() async => (await _client.dio.get('/accounts')).data;
  Future<void> disconnect(String id) async => await _client.dio.delete('/accounts/$id');
  Future<Map<String,dynamic>> sync(String id) async => (await _client.dio.post('/accounts/$id/sync')).data;
  Future<List<dynamic>> getPermissions(String id) async => (await _client.dio.get('/accounts/$id/permissions')).data;
  Future<void> revokePermission(String permId) async => await _client.dio.delete('/accounts/permissions/$permId');
}
