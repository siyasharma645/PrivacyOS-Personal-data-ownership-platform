
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/graph_api.dart';
import '../models/graph.dart';

final graphProvider = FutureProvider<GraphData>((ref) async {
  final data = await GraphApi().get();
  return GraphData.fromJson(data);
});
