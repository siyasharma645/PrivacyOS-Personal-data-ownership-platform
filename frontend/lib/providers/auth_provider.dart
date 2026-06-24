
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/auth_api.dart';
import '../api/api_client.dart';
import '../models/user.dart';

class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  const AuthState({this.user,this.isAuthenticated=false,this.isLoading=false,this.error});
  AuthState copyWith({User? user,bool? isAuthenticated,bool? isLoading,String? error}) =>
    AuthState(user:user??this.user,isAuthenticated:isAuthenticated??this.isAuthenticated,isLoading:isLoading??this.isLoading,error:error);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApi _api = AuthApi();
  final ApiClient _client = ApiClient();
  AuthNotifier() : super(const AuthState()) { _tryAutoLogin(); }

  Future<void> _tryAutoLogin() async {
    final token = await _client.getAccessToken();
    if (token == null) return;
    try {
      final data = await _api.me();
      state = AuthState(user: User.fromJson(data), isAuthenticated: true);
    } catch (_) { await _client.clearTokens(); }
  }

  Future<String?> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.login(email, password);
      final r = AuthResponse.fromJson(data);
      await _client.setTokens(r.accessToken, r.refreshToken);
      state = AuthState(user: r.user, isAuthenticated: true);
      return null;
    } catch (e) {
      final msg = _errorMsg(e);
      state = AuthState(error: msg);
      return msg;
    }
  }

  Future<String?> register(String email, String password, String fullName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.register(email, password, fullName);
      final r = AuthResponse.fromJson(data);
      await _client.setTokens(r.accessToken, r.refreshToken);
      state = AuthState(user: r.user, isAuthenticated: true);
      return null;
    } catch (e) {
      final msg = _errorMsg(e);
      state = AuthState(error: msg);
      return msg;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    await _client.clearTokens();
    state = const AuthState();
  }

  String _errorMsg(dynamic e) {
    try {
      final data = (e as dynamic).response?.data;
      return data['message'] ?? 'An error occurred';
    } catch (_) { return 'An error occurred'; }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
