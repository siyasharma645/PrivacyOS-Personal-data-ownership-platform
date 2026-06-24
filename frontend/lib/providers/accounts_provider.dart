
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/accounts_api.dart';
import '../models/account.dart';

final accountsProvider = FutureProvider<List<ConnectedAccount>>((ref) async {
  final data = await AccountsApi().list();
  return data.map((e) => ConnectedAccount.fromJson(e)).toList();
});
