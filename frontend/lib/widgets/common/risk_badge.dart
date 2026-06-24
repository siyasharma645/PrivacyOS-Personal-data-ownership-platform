
import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class RiskBadge extends StatelessWidget {
  final String level; final bool small;
  const RiskBadge({super.key, required this.level, this.small = false});
  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(level);
    final icons = {'LOW': '✓', 'MEDIUM': '⚠', 'HIGH': '▲', 'CRITICAL': '✕'};
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 6 : 8, vertical: small ? 2 : 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icons[level.toUpperCase()] ?? '?', style: TextStyle(color: color, fontSize: small ? 10 : 11)),
        const SizedBox(width: 3),
        Text(level.toUpperCase(), style: TextStyle(color: color, fontSize: small ? 10 : 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
