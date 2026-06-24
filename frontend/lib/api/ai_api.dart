
import 'api_client.dart';

class AiApi {
  final _client = ApiClient();
  Future<String> chat(String message,List<Map<String,String>> history) async {
    final res = await _client.dio.post('/ai/chat',data:{'message':message,'history':history});
    return res.data['response'] ?? '';
  }
  Future<String> explainPermission(String id) async {
    final res = await _client.dio.post('/ai/explain/permission/$id');
    return res.data['explanation'] ?? '';
  }
}
