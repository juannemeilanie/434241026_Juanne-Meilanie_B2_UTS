import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:utsmobile/presentation/providers/auth_provider.dart';
import 'package:utsmobile/presentation/screens/main_scaffold.dart';
import 'package:utsmobile/presentation/screens/splash/splash_screen.dart';
import 'package:utsmobile/presentation/screens/auth/login_screen.dart';
import 'package:utsmobile/presentation/screens/auth/forgot_password_screen.dart';
import 'package:utsmobile/presentation/screens/auth/register_screen.dart';
import 'package:utsmobile/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:utsmobile/presentation/screens/ticket/ticket_list_screen.dart';
import 'package:utsmobile/presentation/screens/ticket/ticket_detail_screen.dart';
import 'package:utsmobile/presentation/screens/ticket/create_ticket_screen.dart';
import 'package:utsmobile/presentation/screens/notification/notification_screen.dart';
import 'package:utsmobile/presentation/screens/profile/profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authProvider.isLoggedIn;
      final loc = state.matchedLocation;

      if (loc == '/splash') return null;

      final publicRoutes = ['/login', '/register', '/forgot-password'];
      final isPublic = publicRoutes.contains(loc);

      if (!isLoggedIn && !isPublic) return '/login';
      if (isLoggedIn && loc == '/login') return '/dashboard';
      return null;
    },
    refreshListenable: authProvider,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/tickets',
            builder: (context, state) => const TicketListScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/create-ticket',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateTicketScreen(),
      ),

      GoRoute(
        path: '/tickets/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => TicketDetailScreen(
          ticketId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
}
