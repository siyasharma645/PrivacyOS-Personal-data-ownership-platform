
import 'api_client.dart';

class DashboardApi {
  final _client = ApiClient();
  Future<Map<String,dynamic>> get() async => (await _client.dio.get('/dashboard')).data;
  Future<Map<String,dynamic>> getScore() async => (await _client.dio.get('/dashboard/score')).data;
  Future<Map<String,dynamic>> recalculate() async => (await _client.dio.post('/dashboard/score/recalculate')).data;
}
