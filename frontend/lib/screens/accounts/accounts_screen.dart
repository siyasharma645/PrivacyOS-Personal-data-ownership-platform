
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/accounts_api.dart';
import '../../models/account.dart';
import '../../providers/accounts_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/risk_badge.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/provider_icon.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});
  @override ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  final _api = AccountsApi();
  String? _expandedId;

  Future<void> _disconnect(String id, String provider) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface, title: const Text('Disconnect Account', style: TextStyle(color: AppColors.textPrimary)),
      content: Text('Disconnect $provider? This will remove all associated permissions.', style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
          child: const Text('Disconnect')),
      ]));
    if (ok != true) return;
    try {
      await _api.disconnect(id);
      ref.refresh(accountsProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account disconnected')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.critical));
    }
  }

  Future<void> _sync(String id) async {
    try { await _api.sync(id); ref.refresh(accountsProvider); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account synced'))); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync failed: $e'), backgroundColor: AppColors.critical)); }
  }

  Future<void> _revoke(String permId) async {
    try { await _api.revokePermission(permId); ref.refresh(accountsProvider); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission revoked'))); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.critical)); }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    return accountsAsync.when(
      loading: () => const LoadingView(message: 'Loading accounts...'),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.refresh(accountsProvider)),
      data: (accounts) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader(
            title: 'Connected Accounts',
            subtitle: '${accounts.length} account${accounts.length != 1 ? 's' : ''} connected',
            action: TextButton.icon(onPressed: () => ref.refresh(accountsProvider),
              icon: const Icon(Icons.refresh, size: 16), label: const Text('Refresh')),
          ),
          const SizedBox(height: 20),
          if (accounts.isEmpty)
            EmptyView(icon: Icons.link_off, title: 'No accounts connected',
              description: 'Connect accounts via the backend OAuth flow to start monitoring your permissions.')
          else
            ...accounts.map((acc) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AccountCard(account: acc, expanded: _expandedId == acc.id,
                onToggle: () => setState(() => _expandedId = _expandedId == acc.id ? null : acc.id),
                onDisconnect: () => _disconnect(acc.id, acc.provider),
                onSync: () => _sync(acc.id),
                onRevoke: _revoke),
            )),
        ]),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final ConnectedAccount account; final bool expanded;
  final VoidCallback onToggle, onDisconnect, onSync;
  final void Function(String) onRevoke;
  const _AccountCard({required this.account, required this.expanded, required this.onToggle, required this.onDisconnect, required this.onSync, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          ProviderIcon(provider: account.provider, size: 40),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(account.provider, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: account.status == 'ACTIVE' ? AppColors.low.withOpacity(0.12) : AppColors.critical.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20), border: Border.all(color: account.status == 'ACTIVE' ? AppColors.low.withOpacity(0.3) : AppColors.critical.withOpacity(0.3))),
                child: Text(account.status, style: TextStyle(color: account.status == 'ACTIVE' ? AppColors.low : AppColors.critical, fontSize: 10, fontWeight: FontWeight.w600))),
            ]),
            Text(account.providerEmail, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.security, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('${account.permissionCount} permissions', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              if (account.highRiskCount > 0) ...[
                const SizedBox(width: 12),
                Icon(Icons.warning_amber, size: 12, color: AppColors.high),
                const SizedBox(width: 3),
                Text('${account.highRiskCount} high-risk', style: const TextStyle(color: AppColors.high, fontSize: 11)),
              ],
              if (account.lastSyncedAt != null) ...[
                const SizedBox(width: 12),
                Text(formatRelativeTime(account.lastSyncedAt), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ]),
          ])),
          Row(children: [
            OutlinedButton.icon(onPressed: onSync, icon: const Icon(Icons.refresh, size: 14), label: const Text('Sync'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), visualDensity: VisualDensity.compact)),
            const SizedBox(width: 8),
            IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.critical, size: 18), onPressed: onDisconnect),
            IconButton(icon: Icon(expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textMuted, size: 20), onPressed: onToggle),
          ]),
        ])),
        if (expanded) ...[
          const Divider(height: 1, color: AppColors.border),
          Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PERMISSIONS (${account.permissions.length})',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
            const SizedBox(height: 10),
            if (account.permissions.isEmpty) const Text('No active permissions', style: TextStyle(color: AppColors.textMuted, fontSize: 13))
            else ...account.permissions.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(p.displayName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
                    RiskBadge(level: p.riskLevel, small: true),
                    if (p.sensitive) ...[const SizedBox(width: 6),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.purple.withOpacity(0.3))),
                        child: const Text('Sensitive', style: TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.w600)))],
                    if (p.revocable) ...[const SizedBox(width: 6),
                      GestureDetector(onTap: () => onRevoke(p.id),
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.critical.withOpacity(0.1), borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.critical.withOpacity(0.3))),
                          child: const Text('Revoke', style: TextStyle(color: AppColors.critical, fontSize: 11, fontWeight: FontWeight.w500))))],
                  ]),
                  if (p.description.isNotEmpty) ...[const SizedBox(height: 4),
                    Text(p.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 11))],
                  if (p.dataTypes.isNotEmpty) ...[const SizedBox(height: 6),
                    Wrap(spacing: 4, runSpacing: 4, children: p.dataTypes.map((dt) =>
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.surface3, borderRadius: BorderRadius.circular(4)),
                        child: Text(dt, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)))).toList())],
                ]),
              ),
            )),
          ])),
        ],
      ]),
    );
  }
}
