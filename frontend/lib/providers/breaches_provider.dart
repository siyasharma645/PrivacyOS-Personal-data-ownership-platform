import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/breach.dart';

final breachesProvider =
    FutureProvider<List<BreachRecord>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));

  return [
    BreachRecord(
      id: 'breach-001',
      breachName: 'Example Data Exposure',
      title: 'Email addresses and passwords exposed',
      domain: 'example-service.com',
      breachDate: '2025-11-15',
      description:
          'A third-party service experienced a security incident that exposed account information.',
      logoPath: null,
      dataClasses: [
        'Email addresses',
        'Passwords',
        'Usernames',
      ],
      pwnCount: 1250000,
      verified: true,
      sensitive: true,
      remediated: false,
      createdAt: '2026-08-01T10:00:00Z',
    ),
    BreachRecord(
      id: 'breach-002',
      breachName: 'Legacy Service Breach',
      title: 'Account information exposed',
      domain: 'legacy-service.com',
      breachDate: '2024-08-20',
      description:
          'Previously reported exposure involving account metadata and contact information.',
      logoPath: null,
      dataClasses: [
        'Email addresses',
        'Names',
      ],
      pwnCount: 480000,
      verified: true,
      sensitive: false,
      remediated: false,
      createdAt: '2026-07-15T10:00:00Z',
    ),
  ];
});
