
import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class LoadingView extends StatelessWidget {
  final String? message;
  const LoadingView({super.key, this.message});
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircularProgressIndicator(color: AppColors.brand, strokeWidth: 2),
      if (message != null) ...[
        const SizedBox(height: 16),
        Text(message!, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
      ],
    ]));
  }
}

class ErrorView extends StatelessWidget {
  final String message; final VoidCallback? onRetry;
  const ErrorView({super.key, required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, color: AppColors.critical, size: 48),
      const SizedBox(height: 12),
      Text(message, style: const TextStyle(color: AppColors.textMuted, fontSize: 13), textAlign: TextAlign.center),
      if (onRetry != null) ...[
        const SizedBox(height: 16),
        OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh, size: 16), label: const Text('Retry')),
      ],
    ]));
  }
}

class EmptyView extends StatelessWidget {
  final IconData icon; final String title; final String? description; final Widget? action;
  const EmptyView({super.key, required this.icon, required this.title, this.description, this.action});
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 56, height: 56,
        decoration: BoxDecoration(color: AppColors.surface2, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.textMuted, size: 28)),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
      if (description != null) ...[
        const SizedBox(height: 4),
        Text(description!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12), textAlign: TextAlign.center),
      ],
      if (action != null) ...[const SizedBox(height: 16), action!],
    ]));
  }
}
