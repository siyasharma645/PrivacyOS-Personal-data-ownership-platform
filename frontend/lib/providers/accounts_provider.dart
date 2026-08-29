import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';

final accountsProvider =
    FutureProvider<List<ConnectedAccount>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));

  return [
    ConnectedAccount(
      id: 'account-google',
      provider: 'GOOGLE',
      providerEmail: 'demo@privacyos.io',
      displayName: 'Google',
      status: 'ACTIVE',
      avatarUrl: null,
      riskContribution: 12,
      permissionCount: 5,
      highRiskCount: 1,
      scopes: [
        'Profile',
        'Email',
        'Contacts',
      ],
      permissions: [],
      lastSyncedAt: '2026-08-29T10:30:00Z',
      createdAt: '2026-06-10T10:30:00Z',
    ),
    ConnectedAccount(
      id: 'account-github',
      provider: 'GITHUB',
      providerEmail: 'siya-dev',
      displayName: 'GitHub',
      status: 'ACTIVE',
      avatarUrl: null,
      riskContribution: 8,
      permissionCount: 3,
      highRiskCount: 0,
      scopes: [
        'Repositories',
        'Profile',
        'Email',
      ],
      permissions: [],
      lastSyncedAt: '2026-08-29T09:15:00Z',
      createdAt: '2026-06-15T09:15:00Z',
    ),
    ConnectedAccount(
      id: 'account-linkedin',
      provider: 'LINKEDIN',
      providerEmail: 'demo@privacyos.io',
      displayName: 'LinkedIn',
      status: 'ACTIVE',
      avatarUrl: null,
      riskContribution: 15,
      permissionCount: 4,
      highRiskCount: 1,
      scopes: [
        'Profile',
        'Email',
        'Connections',
      ],
      permissions: [],
      lastSyncedAt: '2026-08-28T16:00:00Z',
      createdAt: '2026-07-01T16:00:00Z',
    ),
    ConnectedAccount(
      id: 'account-discord',
      provider: 'DISCORD',
      providerEmail: 'demo@privacyos.io',
      displayName: 'Discord',
      status: 'ACTIVE',
      avatarUrl: null,
      riskContribution: 6,
      permissionCount: 2,
      highRiskCount: 0,
      scopes: [
        'Identity',
        'Email',
      ],
      permissions: [],
      lastSyncedAt: '2026-08-27T12:00:00Z',
      createdAt: '2026-07-20T12:00:00Z',
    ),
  ];
});
