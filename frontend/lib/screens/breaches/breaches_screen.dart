
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/breaches_api.dart';
import '../../models/breach.dart';
import '../../providers/breaches_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/section_header.dart';

class BreachesScreen extends ConsumerWidget {
  const BreachesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(breachesProvider);
    return async.when(
      loading: () => const LoadingView(message: 'Loading breaches...'),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.refresh(breachesProvider)),
      data: (breaches) {
        final active = breaches.where((b) => !b.remediated).toList();
        final resolved = breaches.where((b) => b.remediated).toList();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionHeader(
              title: 'Breach Monitor',
              subtitle: 'Data breaches that may have exposed your personal information',
              action: ElevatedButton.icon(
                icon: const Icon(Icons.search, size: 16),
                label: const Text('Check Now'),
                onPressed: () async {
                  try {
                    await BreachesApi().check();
                    ref.refresh(breachesProvider);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Breach check complete')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.critical));
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            // Summary
            Row(children: [
              _SummaryTile('${active.length}', 'Active Breaches', AppColors.critical),
              const SizedBox(width: 12),
              _SummaryTile('${resolved.length}', 'Resolved', AppColors.low),
              const SizedBox(width: 12),
              _SummaryTile('${breaches.length}', 'Total Found', AppColors.textPrimary),
            ]),
            const SizedBox(height: 24),
            if (active.isNotEmpty) ...[
              Row(children: [
                const Icon(Icons.warning_amber, color: AppColors.critical, size: 16),
                const SizedBox(width: 6),
                Text('ACTIVE BREACHES (${active.length})', style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
              ]),
              const SizedBox(height: 10),
              ...active.map((b) => Padding(padding: const EdgeInsets.only(bottom: 12),
                child: _BreachCard(breach: b, onRemediate: () async {
                  await BreachesApi().remediate(b.id);
                  ref.refresh(breachesProvider);
                }))),
              const SizedBox(height: 20),
            ],
            if (resolved.isNotEmpty) ...[
              Row(children: [
                const Icon(Icons.check_circle_outline, color: AppColors.low, size: 16),
                const SizedBox(width: 6),
                Text('RESOLVED (${resolved.length})', style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
              ]),
              const SizedBox(height: 10),
              Opacity(opacity: 0.55, child: Column(children: resolved.map((b) =>
                Padding(padding: const EdgeInsets.only(bottom: 10), child: _BreachCard(breach: b))).toList())),
            ],
            if (breaches.isEmpty)
              const EmptyView(icon: Icons.shield_outlined, title: 'No breaches found',
                description: "Your email hasn't appeared in any known data breaches. Tap Check Now to run a fresh scan."),
          ]),
        );
      },
    );
  }

  Widget _SummaryTile(String value, String label, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11), textAlign: TextAlign.center),
      ]),
    ));
  }
}

class _BreachCard extends StatelessWidget {
  final BreachRecord breach; final VoidCallback? onRemediate;
  const _BreachCard({required this.breach, this.onRemediate});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: breach.remediated ? AppColors.border : AppColors.critical.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: breach.remediated ? AppColors.surface2 : AppColors.critical.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.shield_outlined, color: breach.remediated ? AppColors.textMuted : AppColors.critical, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(breach.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              if (!breach.remediated) _chip('Action Required', AppColors.critical),
              if (breach.remediated) _chip('Resolved', AppColors.low),
              if (breach.sensitive) ...[const SizedBox(width: 6), _chip('Sensitive', Colors.purple)],
            ]),
            const SizedBox(height: 2),
            Row(children: [
              if (breach.breachDate != null) Text(formatDate(breach.breachDate), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              if (breach.pwnCount != null) ...[
                const SizedBox(width: 12),
                Text('${formatNumber(breach.pwnCount)} affected', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
              if (breach.domain != null) ...[const SizedBox(width: 12), Text(breach.domain!, style: const TextStyle(color: AppColors.textMuted, fontSize: 11))],
            ]),
          ])),
          if (onRemediate != null)
            OutlinedButton.icon(onPressed: onRemediate, icon: const Icon(Icons.check, size: 14), label: const Text('Resolve'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), visualDensity: VisualDensity.compact)),
        ]),
        if (breach.description != null) ...[const SizedBox(height: 8),
          Text(breach.description!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis)],
        if (breach.dataClasses.isNotEmpty) ...[const SizedBox(height: 8),
          Wrap(spacing: 4, runSpacing: 4, children: breach.dataClasses.map((dc) =>
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.critical.withOpacity(0.08), borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.critical.withOpacity(0.2))),
              child: Text(dc, style: const TextStyle(color: AppColors.critical, fontSize: 10)))).toList())],
      ]),
    );
  }
  Widget _chip(String label, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)));
}
