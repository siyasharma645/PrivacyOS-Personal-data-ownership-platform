import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dashboard.dart';
import '../models/score.dart';

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  // Frontend demo data — no backend required.
  await Future.delayed(const Duration(milliseconds: 400));

  return const DashboardData(
    privacyScore: 72,
    previousScore: 68,
    scoreChange: 4,
    riskLevel: 'MEDIUM',
    connectedAccounts: 8,
    activePermissions: 14,
    highRiskPermissions: 3,
    unresolvedBreaches: 2,
    pendingRecommendations: 5,
    scoreHistory: [
      ScoreDataPoint(date: 'Aug 01', score: 61),
      ScoreDataPoint(date: 'Aug 05', score: 64),
      ScoreDataPoint(date: 'Aug 10', score: 63),
      ScoreDataPoint(date: 'Aug 15', score: 67),
      ScoreDataPoint(date: 'Aug 20', score: 69),
      ScoreDataPoint(date: 'Aug 25', score: 71),
      ScoreDataPoint(date: 'Aug 29', score: 72),
    ],
  );
});

final scoreProvider = FutureProvider<PrivacyScoreData>((ref) async {
  // Frontend demo data — no backend required.
  await Future.delayed(const Duration(milliseconds: 300));

  return const PrivacyScoreData(
    score: 72,
    permissionPenalty: 8,
    breachPenalty: 10,
    thirdPartyPenalty: 4,
    sprawlPenalty: 3,
    stalenessPenalty: 3,
    riskLevel: 'MEDIUM',
    breakdown: {
      'Permissions': 8,
      'Breaches': 10,
      'Third-party access': 4,
      'Account sprawl': 3,
      'Stale permissions': 3,
    },
  );
});
