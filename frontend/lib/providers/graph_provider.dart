import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/graph.dart';

final graphProvider =
    FutureProvider<GraphData>((ref) async {
  await Future.delayed(const Duration(milliseconds: 400));

  return const GraphData(
    nodes: [
      GraphNode(
        id: 'user',
        type: 'USER',
        label: 'You',
        riskLevel: 'LOW',
        data: {
          'email': 'demo@privacyos.io',
        },
      ),
      GraphNode(
        id: 'google',
        type: 'ACCOUNT',
        label: 'Google',
        riskLevel: 'MEDIUM',
        data: {
          'permissions': 5,
        },
      ),
      GraphNode(
        id: 'github',
        type: 'ACCOUNT',
        label: 'GitHub',
        riskLevel: 'LOW',
        data: {
          'permissions': 3,
        },
      ),
      GraphNode(
        id: 'linkedin',
        type: 'ACCOUNT',
        label: 'LinkedIn',
        riskLevel: 'MEDIUM',
        data: {
          'permissions': 4,
        },
      ),
      GraphNode(
        id: 'discord',
        type: 'ACCOUNT',
        label: 'Discord',
        riskLevel: 'LOW',
        data: {
          'permissions': 2,
        },
      ),
      GraphNode(
        id: 'breach',
        type: 'BREACH',
        label: 'Data Breach',
        riskLevel: 'HIGH',
        data: {
          'affectedData': 'Email, Password',
        },
      ),
    ],
    edges: [
      GraphEdge(
        id: 'edge-1',
        source: 'user',
        target: 'google',
        label: 'CONNECTED',
        type: 'ACCOUNT',
      ),
      GraphEdge(
        id: 'edge-2',
        source: 'user',
        target: 'github',
        label: 'CONNECTED',
        type: 'ACCOUNT',
      ),
      GraphEdge(
        id: 'edge-3',
        source: 'user',
        target: 'linkedin',
        label: 'CONNECTED',
        type: 'ACCOUNT',
      ),
      GraphEdge(
        id: 'edge-4',
        source: 'user',
        target: 'discord',
        label: 'CONNECTED',
        type: 'ACCOUNT',
      ),
      GraphEdge(
        id: 'edge-5',
        source: 'google',
        target: 'breach',
        label: 'EXPOSED',
        type: 'RISK',
      ),
    ],
  );
});
