
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/recommendations_api.dart';
import '../models/recommendation.dart';

final recommendationsProvider = FutureProvider<List<PrivacyRecommendation>>((ref) async {
  final data = await RecommendationsApi().list();
  return data.map((e) => PrivacyRecommendation.fromJson(e)).toList();
});
