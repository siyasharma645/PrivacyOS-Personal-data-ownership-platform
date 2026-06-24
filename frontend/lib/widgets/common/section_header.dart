
import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class SectionHeader extends StatelessWidget {
  final String title; final String? subtitle; final Widget? action;
  const SectionHeader({super.key, required this.title, this.subtitle, this.action});
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ],
      ])),
      if (action != null) action!,
    ]);
  }
}
