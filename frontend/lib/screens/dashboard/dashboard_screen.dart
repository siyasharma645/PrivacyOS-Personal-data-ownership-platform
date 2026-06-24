
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/risk_badge.dart';
import '../../widgets/common/provider_icon.dart';
import '../../widgets/dashboard/score_ring.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardProvider);
    final user = ref.watch(authProvider).user;

    return dashAsync.when(
      loading: () => const LoadingView(message: 'Loading dashboard...'),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.refresh(dashboardProvider)),
      data: (d) {
        final scoreColor = AppColors.scoreColor(d.privacyScore);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Good ${_greeting()}, ${user?.fullName.split(' ').first ?? 'there'} 👋',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                const Text("Here's your privacy overview", style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ])),
              OutlinedButton.icon(
                onPressed: () => ref.refresh(dashboardProvider),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
              ),
            ]),
            const SizedBox(height: 24),

            // Score + Stats Row
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Score Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  ScoreRing(score: d.privacyScore, size: 100),
                  const SizedBox(width: 20),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('PRIVACY SCORE', style: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 0.8, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    RiskBadge(level: d.riskLevel),
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(d.scoreChange >= 0 ? Icons.trending_up : Icons.trending_down,
                        size: 14, color: d.scoreChange >= 0 ? AppColors.low : AppColors.critical),
                      const SizedBox(width: 4),
                      Text('${d.scoreChange >= 0 ? '+' : ''}${d.scoreChange} this week',
                        style: TextStyle(color: d.scoreChange >= 0 ? AppColors.low : AppColors.critical, fontSize: 12, fontWeight: FontWeight.w500)),
                    ]),
                  ]),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(children: [
                Row(children: [
                  Expanded(child: StatCard(label: 'ACCOUNTS', value: '${d.connectedAccounts}', icon: Icons.link, iconColor: AppColors.info, subtitle: 'Connected')),
                  const SizedBox(width: 10),
                  Expanded(child: StatCard(label: 'PERMISSIONS', value: '${d.activePermissions}', icon: Icons.warning_amber_outlined, iconColor: AppColors.medium, subtitle: '${d.highRiskPermissions} high-risk')),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: StatCard(label: 'BREACHES', value: '${d.unresolvedBreaches}', icon: Icons.shield_outlined,
                    iconColor: d.unresolvedBreaches > 0 ? AppColors.critical : AppColors.low,
                    subtitle: d.unresolvedBreaches > 0 ? 'Action needed' : 'All clear')),
                  const SizedBox(width: 10),
                  Expanded(child: StatCard(label: 'ACTIONS', value: '${d.pendingRecommendations}', icon: Icons.lightbulb_outline, iconColor: AppColors.brand, subtitle: 'Pending')),
                ]),
              ])),
            ]),
            const SizedBox(height: 20),

            // Score Chart
            if (d.scoreHistory.length > 1) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Expanded(child: Text('Privacy Score History', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600))),
                    const Text('Last 30 days', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(height: 160, child: LineChart(LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 1)),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32,
                        getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)))),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
                        getTitlesWidget: (v, meta) {
                          final i = v.toInt();
                          if (i < 0 || i >= d.scoreHistory.length) return const SizedBox();
                          return Text(d.scoreHistory[i].date, style: const TextStyle(color: AppColors.textMuted, fontSize: 10));
                        })),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: 0, maxY: 100,
                    lineBarsData: [LineChartBarData(
                      spots: d.scoreHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.score.toDouble())).toList(),
                      isCurved: true, color: scoreColor, barWidth: 2.5, dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: scoreColor.withOpacity(0.15)),
                    )],
                  ))),
                ]),
              ),
              const SizedBox(height: 20),
            ],

            // Quick Actions
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Quick Actions', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.2,
                  children: [
                    _QuickLink('/graph', Icons.account_tree_outlined, 'Data Graph', 'Visualize connections', context),
                    _QuickLink('/breaches', Icons.shield_outlined, 'Breaches', 'Check exposure', context),
                    _QuickLink('/timeline', Icons.timeline_outlined, 'Timeline', 'Privacy history', context),
                    _QuickLink('/ai-assistant', Icons.smart_toy_outlined, 'AI Assistant', 'Get guidance', context),
                  ]),
              ])),
            ]),
          ]),
        );
      },
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning'; if (h < 17) return 'afternoon'; return 'evening';
  }

  Widget _QuickLink(String path, IconData icon, String label, String desc, BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(path),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Icon(icon, color: AppColors.brand, size: 20),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
            Text(desc, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ]),
        ]),
      ),
    );
  }
}
