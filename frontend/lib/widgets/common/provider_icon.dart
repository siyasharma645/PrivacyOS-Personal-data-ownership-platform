
import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class ProviderIcon extends StatelessWidget {
  final String provider; final double size;
  const ProviderIcon({super.key, required this.provider, this.size = 36});
  @override
  Widget build(BuildContext context) {
    final color = AppColors.providerColor(provider);
    final labels = {'GOOGLE':'G','GITHUB':'GH','LINKEDIN':'in','FACEBOOK':'f','TWITTER':'X','MICROSOFT':'M'};
    final label = labels[provider.toUpperCase()] ?? provider.isNotEmpty ? provider[0].toUpperCase() : '?';
    return Container(width: size, height: size,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size * 0.25)),
      child: Center(child: Text(label, style: TextStyle(color: Colors.white, fontSize: size * 0.35, fontWeight: FontWeight.w700))));
  }
}
