import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/accounts/accounts_screen.dart';
import 'screens/breaches/breaches_screen.dart';
import 'screens/recommendations/recommendations_screen.dart';
import 'screens/timeline/timeline_screen.dart';
import 'screens/graph/graph_screen.dart';
import 'screens/ai/ai_assistant_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'widgets/common/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/accounts', builder: (_, __) => const AccountsScreen()),
          GoRoute(path: '/breaches', builder: (_, __) => const BreachesScreen()),
          GoRoute(path: '/recommendations', builder: (_, __) => const RecommendationsScreen()),
          GoRoute(path: '/timeline', builder: (_, __) => const TimelineScreen()),
          GoRoute(path: '/graph', builder: (_, __) => const GraphScreen()),
          GoRoute(path: '/ai-assistant', builder: (_, __) => const AiAssistantScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
