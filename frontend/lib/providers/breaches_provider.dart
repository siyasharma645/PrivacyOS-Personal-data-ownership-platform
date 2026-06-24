
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/breaches_api.dart';
import '../models/breach.dart';

final breachesProvider = FutureProvider<List<BreachRecord>>((ref) async {
  final data = await BreachesApi().list();
  return data.map((e) => BreachRecord.fromJson(e)).toList();
});
