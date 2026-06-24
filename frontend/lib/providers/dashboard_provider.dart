
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/dashboard_api.dart';
import '../models/dashboard.dart';
import '../models/score.dart';

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final data = await DashboardApi().get();
  return DashboardData.fromJson(data);
});

final scoreProvider = FutureProvider<PrivacyScoreData>((ref) async {
  final data = await DashboardApi().getScore();
  return PrivacyScoreData.fromJson(data);
});
