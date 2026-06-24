
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/graph.dart';
import '../../providers/graph_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/section_header.dart';
import 'dart:math' as math;

class GraphScreen extends ConsumerStatefulWidget {
  const GraphScreen({super.key});
  @override ConsumerState<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends ConsumerState<GraphScreen> {
  String? _selectedNode;
  final _transform = TransformationController();

  @override
  void dispose() { _transform.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(graphProvider);
    return async.when(
      loading: () => const LoadingView(message: 'Building data graph...'),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.refresh(graphProvider)),
      data: (graph) {
        if (graph.nodes.isEmpty) return const EmptyView(icon: Icons.account_tree_outlined, title: 'No graph data', description: 'Connect accounts to visualize your data ownership graph.');

        final nodePositions = _computeLayout(graph);
        final selected = _selectedNode != null ? graph.nodes.firstWhere((n) => n.id == _selectedNode, orElse: () => graph.nodes.first) : null;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionHeader(
              title: 'Data Ownership Graph',
              subtitle: '${graph.nodes.length} nodes · ${graph.edges.length} relationships',
              action: Row(mainAxisSize: MainAxisSize.min, children: [
                OutlinedButton.icon(onPressed: () { _transform.value = Matrix4.identity(); setState(() => _selectedNode = null); },
                  icon: const Icon(Icons.fit_screen, size: 16), label: const Text('Reset')),
                const SizedBox(width: 8),
                OutlinedButton.icon(onPressed: () => ref.refresh(graphProvider),
                  icon: const Icon(Icons.refresh, size: 16), label: const Text('Refresh')),
              ]),
            ),
            const SizedBox(height: 12),
            // Legend
            Wrap(spacing: 16, children: [
              _legend(AppColors.brand, 'You'),
              _legend(const Color(0xFF3B82F6), 'Account'),
              _legend(AppColors.medium, 'Permission'),
              _legend(AppColors.low, 'Data Category'),
            ]),
            const SizedBox(height: 12),
            Expanded(child: Row(children: [
              Expanded(
                flex: 3,
                child: Container(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  clipBehavior: Clip.antiAlias,
                  child: InteractiveViewer(
                    transformationController: _transform,
                    boundaryMargin: const EdgeInsets.all(200),
                    minScale: 0.3, maxScale: 3,
                    child: SizedBox(
                      width: 1200, height: 800,
                      child: CustomPaint(
                        painter: _GraphPainter(graph: graph, positions: nodePositions, selectedId: _selectedNode),
                        child: Stack(children: graph.nodes.map((node) {
                          final pos = nodePositions[node.id] ?? const Offset(0,0);
                          return Positioned(left: pos.dx - 50, top: pos.dy - 24,
                            child: GestureDetector(onTap: () => setState(() => _selectedNode = node.id == _selectedNode ? null : node.id),
                              child: _NodeWidget(node: node, selected: node.id == _selectedNode)));
                        }).toList()),
                      ),
                    ),
                  ),
                ),
              ),
              if (selected != null) ...[
                const SizedBox(width: 12),
                SizedBox(width: 240, child: _NodeDetail(node: selected, graph: graph)),
              ],
            ])),
            const SizedBox(height: 10),
            Row(children: [
              _statChip('Nodes', '${graph.nodes.length}'),
              const SizedBox(width: 8),
              _statChip('Edges', '${graph.edges.length}'),
              const SizedBox(width: 8),
              _statChip('Accounts', '${graph.nodes.where((n) => n.type == "ACCOUNT").length}'),
              const SizedBox(width: 8),
              _statChip('Data Types', '${graph.nodes.where((n) => n.type == "DATA_CATEGORY").length}'),
            ]),
          ]),
        );
      },
    );
  }

  Map<String, Offset> _computeLayout(GraphData graph) {
    final Map<String, Offset> pos = {};
    final byType = <String, List<String>>{};
    for (final n in graph.nodes) {
      byType.putIfAbsent(n.type, () => []).add(n.id);
    }
    final yMap = {'USER': 80.0, 'ACCOUNT': 250.0, 'PERMISSION': 440.0, 'DATA_CATEGORY': 640.0};
    for (final entry in byType.entries) {
      final ids = entry.value;
      final y = yMap[entry.key] ?? 700.0;
      final totalW = (ids.length - 1) * 200.0;
      for (int i = 0; i < ids.length; i++) {
        pos[ids[i]] = Offset(600 + i * 200.0 - totalW / 2, y);
      }
    }
    return pos;
  }

  Widget _legend(Color color, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
  ]);

  Widget _statChip(String label, String value) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
    ]));
}

class _GraphPainter extends CustomPainter {
  final GraphData graph; final Map<String, Offset> positions; final String? selectedId;
  _GraphPainter({required this.graph, required this.positions, this.selectedId});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.border.withOpacity(0.6)..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final selPaint = Paint()..color = AppColors.brand.withOpacity(0.8)..strokeWidth = 2..style = PaintingStyle.stroke;
    for (final edge in graph.edges) {
      final src = positions[edge.source]; final tgt = positions[edge.target];
      if (src == null || tgt == null) continue;
      final isSelected = edge.source == selectedId || edge.target == selectedId;
      canvas.drawLine(src, tgt, isSelected ? selPaint : paint);
    }
  }
  @override bool shouldRepaint(_GraphPainter old) => old.selectedId != selectedId;
}

class _NodeWidget extends StatelessWidget {
  final GraphNode node; final bool selected;
  const _NodeWidget({required this.node, required this.selected});

  Color get _color => switch (node.type) {
    'USER' => AppColors.brand,
    'ACCOUNT' => const Color(0xFF3B82F6),
    'PERMISSION' => AppColors.riskColor(node.riskLevel),
    _ => AppColors.low,
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(duration: const Duration(milliseconds: 150),
      constraints: const BoxConstraints(maxWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: node.type == 'DATA_CATEGORY' ? BorderRadius.circular(20) : BorderRadius.circular(8),
        border: Border.all(color: selected ? _color : _color.withOpacity(0.4), width: selected ? 2 : 1),
        boxShadow: selected ? [BoxShadow(color: _color.withOpacity(0.4), blurRadius: 12)] : [],
      ),
      child: Text(node.label, style: TextStyle(color: _color, fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}

class _NodeDetail extends StatelessWidget {
  final GraphNode node; final GraphData graph;
  const _NodeDetail({required this.node, required this.graph});
  @override
  Widget build(BuildContext context) {
    final connected = graph.edges.where((e) => e.source == node.id || e.target == node.id).length;
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Node Detail', style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
        const SizedBox(height: 10),
        Text(node.label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        _row('Type', node.type),
        _row('Risk', node.riskLevel),
        _row('Connections', '$connected'),
        ...node.data.entries.take(4).map((e) => _row(e.key, '${e.value}')),
      ]));
  }
  Widget _row(String k, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Expanded(child: Text(k, style: const TextStyle(color: AppColors.textMuted, fontSize: 11))),
      Text(v, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
    ]));
}
