import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/auth_api.dart';
import '../api/api_client.dart';
import '../models/user.dart';

class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) =>
      AuthState(
        user: user ?? this.user,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApi _api = AuthApi();
  final ApiClient _client = ApiClient();

  AuthNotifier() : super(const AuthState());

  Future<void> _tryAutoLogin() async {
    // Frontend demo mode.
    // No backend authentication required.
    state = AuthState(
      user: _demoUser,
      isAuthenticated: true,
    );
  }

  Future<String?> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    // Demo login
    if (email.trim() == 'demo@privacyos.io' &&
        password == 'Demo@1234') {
      state = AuthState(
        user: _demoUser,
        isAuthenticated: true,
      );

      return null;
    }

    state = const AuthState(
      error: 'For the live demo, use demo@privacyos.io / Demo@1234',
    );

    return 'For the live demo, use demo@privacyos.io / Demo@1234';
  }

  Future<String?> register(
      String email,
      String password,
      String fullName,
      ) async {
    return 'Registration is disabled in demo mode.';
  }

  Future<void> logout() async {
    state = const AuthState();
  }

  static const User _demoUser = User(
    id: 'demo-user',
    email: 'demo@privacyos.io',
    fullName: 'Demo User',
    riskLevel: 'MEDIUM',
    provider: 'LOCAL',
    role: 'USER',
    avatarUrl: null,
    emailVerified: true,
    privacyScore: 72,
    createdAt: '2026-01-01T00:00:00Z',
  );
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
