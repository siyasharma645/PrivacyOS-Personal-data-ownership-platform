
import 'api_client.dart';

class TimelineApi {
  final _client = ApiClient();
  Future<Map<String,dynamic>> get({int page=0,int size=20}) async =>
    (await _client.dio.get('/timeline',queryParameters:{'page':page,'size':size})).data;
}
