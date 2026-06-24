
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/timeline_api.dart';
import '../models/event.dart';

final timelineProvider = FutureProvider<List<PrivacyEvent>>((ref) async {
  final data = await TimelineApi().get(size: 50);
  return EventPage.fromJson(data).content;
});
