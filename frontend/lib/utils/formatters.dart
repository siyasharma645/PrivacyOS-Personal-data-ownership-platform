import 'package:intl/intl.dart';

String formatDate(String? dateStr) {
  if (dateStr == null) return 'Unknown';
  try {
    final d = DateTime.parse(dateStr);
    return DateFormat('MMM d, yyyy').format(d);
  } catch (_) { return dateStr; }
}

String formatRelativeTime(String? dateStr) {
  if (dateStr == null) return '';
  try {
    final d = DateTime.parse(dateStr);
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '\${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '\${diff.inHours}h ago';
    if (diff.inDays < 7) return '\${diff.inDays}d ago';
    return formatDate(dateStr);
  } catch (_) { return ''; }
}

String formatNumber(num? n) {
  if (n == null) return '0';
  if (n >= 1000000) return '\${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '\${(n / 1000).toStringAsFixed(1)}K';
  return n.toString();
}

String getScoreLabel(int score) {
  if (score >= 80) return 'Good';
  if (score >= 60) return 'Fair';
  if (score >= 40) return 'Poor';
  return 'Critical';
}
