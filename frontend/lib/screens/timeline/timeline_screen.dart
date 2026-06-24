
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event.dart';
import '../../providers/timeline_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/section_header.dart';

const _eventIcons = {
  'ACCOUNT_CONNECTED': '🔗', 'ACCOUNT_DISCONNECTED': '🔌', 'PERMISSION_GRANTED': '✅',
  'PERMISSION_REVOKED': '❌', 'BREACH_DETECTED': '🚨', 'BREACH_REMEDIATED': '🛡',
  'SCORE_CHANGED': '📊', 'PERMISSION_RISK': '⚠', 'PERMISSION_REVOKED_MANUAL': '❌',
};

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});
  @override ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  String _filter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(timelineProvider);
    return async.when(
      loading: () => const LoadingView(message: 'Loading timeline...'),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.refresh(timelineProvider)),
      data: (events) {
        final filtered = _filter == 'ALL' ? events : events.where((e) => e.severity == _filter).toList();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionHeader(title: 'Privacy Timeline', subtitle: 'Complete audit log of your privacy events',
              action: IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.refresh(timelineProvider))),
            const SizedBox(height: 16),
            Wrap(spacing: 8, children: ['ALL','INFO','WARNING','CRITICAL'].map((f) =>
              GestureDetector(onTap: () => setState(() => _filter = f),
                child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _filter == f ? AppColors.brand : AppColors.surface2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _filter == f ? AppColors.brand : AppColors.border)),
                  child: Text(f, style: TextStyle(color: _filter == f ? Colors.white : AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500))))).toList()),
            const SizedBox(height: 16),
            if (filtered.isEmpty) const EmptyView(icon: Icons.timeline_outlined, title: 'No events yet',
              description: 'Privacy events will appear here as you connect accounts and changes are detected.')
            else
              ...filtered.asMap().entries.map((entry) => _TimelineItem(event: entry.value, isLast: entry.key == filtered.length - 1)),
          ]),
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final PrivacyEvent event; final bool isLast;
  const _TimelineItem({required this.event, required this.isLast});

  Color get _severityColor => switch (event.severity) {
    'CRITICAL' => AppColors.critical,
    'WARNING' => AppColors.warning,
    _ => AppColors.info,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _eventIcons[event.eventType] ?? '📋';
    return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(width: 40, child: Column(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: _severityColor.withOpacity(0.12), shape: BoxShape.circle,
            border: Border.all(color: _severityColor.withOpacity(0.4))),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 15)))),
        if (!isLast) Expanded(child: Center(child: Container(width: 2, color: AppColors.border))),
      ])),
      const SizedBox(width: 12),
      Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 16),
        child: Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border(left: BorderSide(color: _severityColor, width: 2), top: const BorderSide(color: AppColors.border), right: const BorderSide(color: AppColors.border), bottom: const BorderSide(color: AppColors.border))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(event.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600))),
              Text(formatRelativeTime(event.createdAt), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ]),
            const SizedBox(height: 3),
            Text(event.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            if (event.scoreBefore != null && event.scoreAfter != null) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Text('Score: ', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                Text('${event.scoreBefore}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(width: 4),
                Icon(event.scoreAfter! > event.scoreBefore! ? Icons.arrow_upward : event.scoreAfter! < event.scoreBefore! ? Icons.arrow_downward : Icons.remove,
                  size: 12, color: event.scoreAfter! > event.scoreBefore! ? AppColors.low : event.scoreAfter! < event.scoreBefore! ? AppColors.critical : AppColors.textMuted),
                const SizedBox(width: 4),
                Text('${event.scoreAfter}', style: TextStyle(color: event.scoreAfter! > event.scoreBefore! ? AppColors.low : event.scoreAfter! < event.scoreBefore! ? AppColors.critical : AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ],
          ])))),
    ]));
  }
}
