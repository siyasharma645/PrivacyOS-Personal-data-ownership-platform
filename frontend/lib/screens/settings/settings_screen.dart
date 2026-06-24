
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/dashboard_api.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/dashboard/score_ring.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _tab = 0;
  final _tabs = ['Profile', 'Privacy', 'Danger Zone'];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final scoreAsync = ref.watch(scoreProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(title: 'Settings', subtitle: 'Manage your account and privacy preferences'),
        const SizedBox(height: 20),
        // Tab bar
        Row(children: List.generate(_tabs.length, (i) => Padding(padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(onTap: () => setState(() => _tab = i),
            child: AnimatedContainer(duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _tab == i ? AppColors.surface2 : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _tab == i ? AppColors.border : Colors.transparent)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon([Icons.person_outline, Icons.shield_outlined, Icons.warning_amber_outlined][i],
                  size: 15, color: _tab == i ? AppColors.textPrimary : AppColors.textMuted),
                const SizedBox(width: 6),
                Text(_tabs[i], style: TextStyle(color: _tab == i ? AppColors.textPrimary : AppColors.textMuted, fontSize: 13, fontWeight: _tab == i ? FontWeight.w600 : FontWeight.w400)),
              ]))))),
        const SizedBox(height: 20),

        // Profile tab
        if (_tab == 0 && user != null) ...[
          _card(children: [
            const _CardTitle('Account Information'),
            const SizedBox(height: 16),
            Row(children: [
              CircleAvatar(radius: 32, backgroundColor: AppColors.brand,
                child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700))),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user.fullName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                Text(user.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 4),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.info.withOpacity(0.3))),
                  child: Text(user.provider, style: const TextStyle(color: AppColors.info, fontSize: 11, fontWeight: FontWeight.w600))),
              ]),
            ]),
            const SizedBox(height: 20),
            _infoRow('Full Name', user.fullName),
            _infoRow('Email', user.email),
            _infoRow('Role', user.role),
            _infoRow('Member Since', formatDate(user.createdAt)),
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerRight,
              child: ElevatedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updates coming soon'))),
                icon: const Icon(Icons.save, size: 16), label: const Text('Save Changes'))),
          ]),
        ],

        // Privacy tab
        if (_tab == 1) ...[
          _card(children: [
            const _CardTitle('Privacy Score Breakdown'),
            const SizedBox(height: 16),
            scoreAsync.when(
              loading: () => const LoadingView(),
              error: (e,_) => Text('Error: $e', style: const TextStyle(color: AppColors.critical)),
              data: (score) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ScoreRing(score: score.score, size: 90),
                const SizedBox(width: 20),
                Expanded(child: Column(children: [
                  _penaltyBar('Permission Risk', score.permissionPenalty, 100),
                  _penaltyBar('Breach Exposure', score.breachPenalty, 100),
                  _penaltyBar('Third-Party Sharing', score.thirdPartyPenalty, 50),
                  _penaltyBar('Account Sprawl', score.sprawlPenalty, 50),
                  _penaltyBar('Data Staleness', score.stalenessPenalty, 50),
                ])),
              ]),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: () async {
              await DashboardApi().recalculate();
              ref.refresh(scoreProvider);
              ref.refresh(dashboardProvider);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Score recalculated')));
            }, icon: const Icon(Icons.refresh, size: 16), label: const Text('Recalculate Score')),
          ]),
          const SizedBox(height: 16),
          _card(children: [
            const _CardTitle('Privacy Preferences'),
            const SizedBox(height: 12),
            ...[
              ('Breach Alerts', 'Get notified when new breaches are detected', true),
              ('Weekly Privacy Report', 'Receive a weekly summary of your privacy posture', true),
              ('High-Risk Permission Warnings', 'Alert when high-risk permissions are detected', true),
            ].map((p) => Padding(padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.$1, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(p.$2, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ])),
                Switch(value: p.$3, activeColor: AppColors.brand, onChanged: (_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings coming soon')))),
              ]))),
          ]),
        ],

        // Danger zone
        if (_tab == 2) ...[
          Container(padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.critical.withOpacity(0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.warning_amber, color: AppColors.critical, size: 18),
                SizedBox(width: 8),
                Text('Danger Zone', style: TextStyle(color: AppColors.critical, fontSize: 15, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 8),
              const Text('These actions are irreversible. Please proceed with caution.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              const SizedBox(height: 20),
              ...[
                ('Clear all privacy data', 'Remove all events, recommendations and score history'),
                ('Delete account', 'Permanently delete your PrivacyOS account and all data'),
              ].map((item) => Padding(padding: const EdgeInsets.only(bottom: 12),
                child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.critical.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.critical.withOpacity(0.2))),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.$1, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                      Text(item.$2, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ])),
                    ElevatedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.$1} not available in demo'), backgroundColor: AppColors.critical)),
                      icon: const Icon(Icons.delete_outline, size: 14),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    ),
                  ])))),
              // Logout
              SizedBox(width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout, size: 16, color: AppColors.critical),
                  label: const Text('Log Out', style: TextStyle(color: AppColors.critical)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.critical), padding: const EdgeInsets.symmetric(vertical: 12)),
                )),
            ])),
        ],
      ]),
    );
  }

  Widget _card({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(20), margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));

  Widget _infoRow(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
      Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(6)),
        child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)))),
    ]));

  Widget _penaltyBar(String label, int value, int max) {
    final ratio = (value / max).clamp(0.0, 1.0);
    final color = ratio > 0.6 ? AppColors.critical : ratio > 0.3 ? AppColors.medium : AppColors.low;
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(children: [
      Row(children: [
        Expanded(child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11))),
        Text('-$value pts', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ]),
      const SizedBox(height: 3),
      ClipRRect(borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: ratio, minHeight: 5, backgroundColor: AppColors.surface3, valueColor: AlwaysStoppedAnimation(color))),
    ]));
  }
}

class _CardTitle extends StatelessWidget {
  final String title;
  const _CardTitle(this.title);
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600));
}
