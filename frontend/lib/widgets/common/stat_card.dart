
import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class StatCard extends StatelessWidget {
  final String label; final String value; final IconData icon;
  final Color iconColor; final String? subtitle; final int? change;
  const StatCard({super.key, required this.label, required this.value, required this.icon,
    this.iconColor = AppColors.brand, this.subtitle, this.change});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 0.5, fontWeight: FontWeight.w600))),
          Container(width: 32, height: 32,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 16)),
        ]),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w700)),
          if (change != null) ...[
            const SizedBox(width: 6),
            Padding(padding: const EdgeInsets.only(bottom: 3),
              child: Text('${change! >= 0 ? '+' : ''}$change',
                style: TextStyle(color: change! >= 0 ? AppColors.low : AppColors.critical, fontSize: 12, fontWeight: FontWeight.w600))),
          ],
        ]),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ]),
    );
  }
}
