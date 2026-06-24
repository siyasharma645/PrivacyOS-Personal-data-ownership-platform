
import 'api_client.dart';

class GraphApi {
  final _client = ApiClient();
  Future<Map<String,dynamic>> get() async => (await _client.dio.get('/graph')).data;
}
