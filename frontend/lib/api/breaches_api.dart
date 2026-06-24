
import 'api_client.dart';

class BreachesApi {
  final _client = ApiClient();
  Future<List<dynamic>> list() async => (await _client.dio.get('/breaches')).data;
  Future<List<dynamic>> check() async => (await _client.dio.post('/breaches/check')).data;
  Future<Map<String,dynamic>> remediate(String id) async => (await _client.dio.post('/breaches/$id/remediate')).data;
}
