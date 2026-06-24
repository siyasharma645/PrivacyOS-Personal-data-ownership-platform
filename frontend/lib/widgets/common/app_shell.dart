
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;
  bool _railExtended = true;

  final _navItems = const [
    _NavItem('/dashboard', Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
    _NavItem('/accounts', Icons.link_outlined, Icons.link, 'Accounts'),
    _NavItem('/breaches', Icons.shield_outlined, Icons.shield, 'Breaches'),
    _NavItem('/recommendations', Icons.lightbulb_outline, Icons.lightbulb, 'Recommendations'),
    _NavItem('/timeline', Icons.timeline_outlined, Icons.timeline, 'Timeline'),
    _NavItem('/graph', Icons.account_tree_outlined, Icons.account_tree, 'Data Graph'),
    _NavItem('/ai-assistant', Icons.smart_toy_outlined, Icons.smart_toy, 'AI Assistant'),
    _NavItem('/settings', Icons.settings_outlined, Icons.settings, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final score = user?.privacyScore ?? 50;
    final scoreColor = AppColors.scoreColor(score);
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(
        children: [
          // Navigation Rail
          Container(
            width: _railExtended ? 220 : 72,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(right: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.security, color: Colors.white, size: 20),
                      ),
                      if (_railExtended) ...[
                        const SizedBox(width: 10),
                        const Text('PrivacyOS', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.chevron_left, size: 18, color: AppColors.textMuted),
                          onPressed: () => setState(() => _railExtended = false)),
                      ] else ...[
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                          onPressed: () => setState(() => _railExtended = true)),
                      ],
                    ],
                  ),
                ),
                // Score card
                if (_railExtended)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40, height: 40,
                          child: Stack(alignment: Alignment.center, children: [
                            CircularProgressIndicator(value: score/100, strokeWidth: 4,
                              color: scoreColor, backgroundColor: AppColors.surface3),
                            Text('$score', style: TextStyle(color: scoreColor, fontSize: 11, fontWeight: FontWeight.w700)),
                          ]),
                        ),
                        const SizedBox(width: 10),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Privacy Score', style: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 0.5)),
                          Text(user?.riskLevel ?? 'MEDIUM',
                            style: TextStyle(color: scoreColor, fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                // Nav items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    itemCount: _navItems.length,
                    itemBuilder: (ctx, i) {
                      final item = _navItems[i];
                      final selected = _selectedIndex == i;
                      return _NavTile(
                        item: item, selected: selected, extended: _railExtended,
                        onTap: () { setState(() => _selectedIndex = i); context.go(item.path); },
                      );
                    },
                  ),
                ),
                // User tile
                if (_railExtended && user != null)
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 16, backgroundColor: AppColors.brand,
                          child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(user.fullName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                          Text(user.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 10), overflow: TextOverflow.ellipsis),
                        ])),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Column(
              children: [
                // Topbar
                Container(
                  height: 56, padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.bg.withOpacity(0.9),
                    border: const Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.textMuted), onPressed: () {}),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () { context.go('/settings'); setState(() => _selectedIndex = 7); },
                        child: CircleAvatar(radius: 16, backgroundColor: AppColors.brand,
                          child: Text(user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
                      ),
                    ],
                  ),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String path, label;
  final IconData icon, activeIcon;
  const _NavItem(this.path, this.icon, this.activeIcon, this.label);
}

class _NavTile extends StatelessWidget {
  final _NavItem item; final bool selected, extended; final VoidCallback onTap;
  const _NavTile({required this.item, required this.selected, required this.extended, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: selected ? AppColors.brand.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? AppColors.brand.withOpacity(0.3) : Colors.transparent),
      ),
      child: ListTile(
        dense: true, onTap: onTap,
        leading: Icon(selected ? item.activeIcon : item.icon,
          color: selected ? AppColors.brandLight : AppColors.textMuted, size: 18),
        title: extended ? Text(item.label, style: TextStyle(
          color: selected ? AppColors.brandLight : AppColors.textSecondary,
          fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)) : null,
        contentPadding: EdgeInsets.symmetric(horizontal: extended ? 12 : 8, vertical: 0),
        minLeadingWidth: 0,
      ),
    );
  }
}
