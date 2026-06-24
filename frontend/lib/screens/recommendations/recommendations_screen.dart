
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/recommendations_api.dart';
import '../../models/recommendation.dart';
import '../../providers/recommendations_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/risk_badge.dart';
import '../../widgets/common/section_header.dart';

const _typeIcons = {
  'REVOKE_PERMISSION': '🔑', 'CHANGE_PASSWORD': '🔒', 'ENABLE_2FA': '📱',
  'REVIEW_PERMISSIONS': '👁', 'REMEDIATE_BREACH': '🚨', 'REDUCE_SPRAWL': '🧹', 'REVIEW_ACCOUNT': '⚙',
};

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recommendationsProvider);
    return async.when(
      loading: () => const LoadingView(message: 'Loading recommendations...'),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.refresh(recommendationsProvider)),
      data: (recs) {
        final pending = recs.where((r) => r.status == 'PENDING').toList();
        final completed = recs.where((r) => r.status == 'COMPLETED').toList();
        final totalGain = pending.fold(0, (s, r) => s + r.expectedScoreImprovement);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionHeader(
              title: 'Recommendations',
              subtitle: 'Actionable steps to improve your privacy score',
              action: ElevatedButton.icon(
                icon: const Icon(Icons.bolt, size: 16), label: const Text('Generate'),
                onPressed: () async {
                  await RecommendationsApi().generate();
                  ref.refresh(recommendationsProvider);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New recommendations generated')));
                },
              ),
            ),
            const SizedBox(height: 20),
            if (pending.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.brand.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.brand.withOpacity(0.25))),
                child: Row(children: [
                  const Icon(Icons.trending_up, color: AppColors.brandLight, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    'Complete all recommendations to gain up to +$totalGain points',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
                ]),
              ),
              const SizedBox(height: 16),
              Text('PENDING (${pending.length})', style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
              const SizedBox(height: 10),
              ...pending.map((r) => Padding(padding: const EdgeInsets.only(bottom: 10),
                child: _RecCard(rec: r,
                  onComplete: () async { await RecommendationsApi().complete(r.id); ref.refresh(recommendationsProvider); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completed! Score updated.'))); },
                  onDismiss: () async { await RecommendationsApi().dismiss(r.id); ref.refresh(recommendationsProvider); }))),
            ],
            if (completed.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('COMPLETED (${completed.length})', style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
              const SizedBox(height: 10),
              Opacity(opacity: 0.5, child: Column(children: completed.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                  child: Row(children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.low, size: 16),
                    const SizedBox(width: 10),
                    Expanded(child: Text(r.title, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, decoration: TextDecoration.lineThrough))),
                    Text('+${r.expectedScoreImprovement}', style: const TextStyle(color: AppColors.low, fontSize: 12, fontWeight: FontWeight.w600)),
                  ])))).toList())),
            ],
            if (recs.isEmpty) const EmptyView(icon: Icons.lightbulb_outline, title: 'No recommendations yet',
              description: "Tap Generate to get personalized privacy recommendations."),
          ]),
        );
      },
    );
  }
}

class _RecCard extends StatelessWidget {
  final PrivacyRecommendation rec; final VoidCallback onComplete, onDismiss;
  const _RecCard({required this.rec, required this.onComplete, required this.onDismiss});
  @override
  Widget build(BuildContext context) {
    final icon = _typeIcons[rec.type] ?? '💡';
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 18)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(rec.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600))),
            RiskBadge(level: rec.priority, small: true),
          ]),
          const SizedBox(height: 4),
          Text(rec.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.5)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.trending_up, size: 13, color: AppColors.low),
            const SizedBox(width: 3),
            Text('+${rec.expectedScoreImprovement} score', style: const TextStyle(color: AppColors.low, fontSize: 11, fontWeight: FontWeight.w500)),
            if (rec.relatedAccountProvider != null) ...[
              const SizedBox(width: 10),
              Text('via ${rec.relatedAccountProvider}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
            const Spacer(),
            GestureDetector(onTap: onDismiss, child: const Icon(Icons.close, size: 16, color: AppColors.textMuted)),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: onComplete,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), visualDensity: VisualDensity.compact),
              child: Text(rec.actionLabel, style: const TextStyle(fontSize: 12))),
          ]),
        ])),
      ]));
  }
}
