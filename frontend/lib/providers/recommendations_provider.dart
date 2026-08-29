import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/recommendation.dart';

final recommendationsProvider =
    FutureProvider<List<PrivacyRecommendation>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));

  return [
    PrivacyRecommendation(
      id: 'recommendation-001',
      type: 'PERMISSION',
      priority: 'HIGH',
      title: 'Review unused Google permissions',
      description:
          'You have permissions that have not been used recently. Review and revoke access you no longer need.',
      status: 'PENDING',
      actionLabel: 'Review Permissions',
      actionUrl: null,
      relatedAccountId: 'account-google',
      relatedAccountProvider: 'GOOGLE',
      createdAt: '2026-08-29T09:00:00Z',
      expectedScoreImprovement: 8,
    ),
    PrivacyRecommendation(
      id: 'recommendation-002',
      type: 'BREACH',
      priority: 'HIGH',
      title: 'Secure your exposed account',
      description:
          'Your account appears in a known data exposure. Consider changing your password and enabling stronger authentication.',
      status: 'PENDING',
      actionLabel: 'Secure Account',
      actionUrl: null,
      relatedAccountId: 'account-google',
      relatedAccountProvider: 'GOOGLE',
      createdAt: '2026-08-28T11:00:00Z',
      expectedScoreImprovement: 10,
    ),
    PrivacyRecommendation(
      id: 'recommendation-003',
      type: 'ACCOUNT',
      priority: 'MEDIUM',
      title: 'Review connected accounts',
      description:
          'Review the applications connected to your digital identity and remove accounts you no longer use.',
      status: 'PENDING',
      actionLabel: 'Review Accounts',
      actionUrl: null,
      relatedAccountId: null,
      relatedAccountProvider: null,
      createdAt: '2026-08-27T14:00:00Z',
      expectedScoreImprovement: 5,
    ),
    PrivacyRecommendation(
      id: 'recommendation-004',
      type: 'SECURITY',
      priority: 'MEDIUM',
      title: 'Enable stronger account security',
      description:
          'Enable multi-factor authentication on important accounts to reduce account takeover risk.',
      status: 'PENDING',
      actionLabel: 'Improve Security',
      actionUrl: null,
      relatedAccountId: 'account-github',
      relatedAccountProvider: 'GITHUB',
      createdAt: '2026-08-25T14:00:00Z',
      expectedScoreImprovement: 4,
    ),
    PrivacyRecommendation(
      id: 'recommendation-005',
      type: 'PRIVACY',
      priority: 'LOW',
      title: 'Review your public profile data',
      description:
          'Check what personal information is publicly visible across your connected profiles.',
      status: 'PENDING',
      actionLabel: 'Review Profile',
      actionUrl: null,
      relatedAccountId: 'account-linkedin',
      relatedAccountProvider: 'LINKEDIN',
      createdAt: '2026-08-23T14:00:00Z',
      expectedScoreImprovement: 3,
    ),
  ];
});
