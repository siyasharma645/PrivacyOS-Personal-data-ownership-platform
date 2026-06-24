
import 'api_client.dart';

class RecommendationsApi {
  final _client = ApiClient();
  Future<List<dynamic>> list() async => (await _client.dio.get('/recommendations')).data;
  Future<Map<String,dynamic>> complete(String id) async => (await _client.dio.post('/recommendations/$id/complete')).data;
  Future<Map<String,dynamic>> dismiss(String id) async => (await _client.dio.post('/recommendations/$id/dismiss')).data;
  Future<void> generate() async => await _client.dio.post('/recommendations/generate');
}
