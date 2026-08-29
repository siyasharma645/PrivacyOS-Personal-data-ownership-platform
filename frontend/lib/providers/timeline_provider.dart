import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event.dart';

final timelineProvider =
    FutureProvider<List<PrivacyEvent>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));

  return [
    PrivacyEvent(
      id: 'event-001',
      eventType: 'ACCOUNT_CONNECTED',
      title: 'Google account connected',
      description:
          'A Google account was connected to your PrivacyOS profile.',
      severity: 'INFO',
      entityType: 'ACCOUNT',
      createdAt: '2026-08-29T10:30:00Z',
      scoreBefore: 70,
      scoreAfter: 72,
    ),
    PrivacyEvent(
      id: 'event-002',
      eventType: 'BREACH_DETECTED',
      title: 'Potential data exposure detected',
      description:
          'PrivacyOS detected your information in a known data breach.',
      severity: 'HIGH',
      entityType: 'BREACH',
      createdAt: '2026-08-28T15:20:00Z',
      scoreBefore: 75,
      scoreAfter: 70,
    ),
    PrivacyEvent(
      id: 'event-003',
      eventType: 'PERMISSION_REVIEW',
      title: 'Permissions reviewed',
      description:
          'Connected account permissions were analyzed for potential privacy risks.',
      severity: 'INFO',
      entityType: 'PERMISSION',
      createdAt: '2026-08-27T12:45:00Z',
      scoreBefore: 68,
      scoreAfter: 70,
    ),
    PrivacyEvent(
      id: 'event-004',
      eventType: 'RISK_DETECTED',
      title: 'High-risk permission detected',
      description:
          'A permission with elevated access was identified on a connected account.',
      severity: 'MEDIUM',
      entityType: 'PERMISSION',
      createdAt: '2026-08-25T09:30:00Z',
      scoreBefore: 72,
      scoreAfter: 68,
    ),
    PrivacyEvent(
      id: 'event-005',
      eventType: 'ACCOUNT_CONNECTED',
      title: 'GitHub account connected',
      description:
          'Your GitHub account was successfully connected to PrivacyOS.',
      severity: 'INFO',
      entityType: 'ACCOUNT',
      createdAt: '2026-08-20T16:00:00Z',
      scoreBefore: 65,
      scoreAfter: 67,
    ),
  ];
});
