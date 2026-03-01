import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:findmydorm/features/auth/domain/models/user_model.dart';
import 'package:findmydorm/features/dorms/domain/models/dorm_model.dart';
import 'package:findmydorm/features/splash/presentation/pages/splash_screen.dart';
import 'package:findmydorm/features/auth/presentation/pages/auth_check_wrapper.dart';
import 'package:findmydorm/features/dorms/presentation/pages/selection_page.dart';
import 'package:findmydorm/features/auth/presentation/pages/login_page.dart';
import 'package:findmydorm/features/auth/presentation/pages/registration_page.dart';
import 'package:findmydorm/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:findmydorm/features/auth/presentation/pages/change_password_page.dart';
import 'package:findmydorm/core/widgets/bottom_navbar.dart';
import 'package:findmydorm/features/dorms/presentation/pages/dorm_detail_page.dart';
import 'package:findmydorm/features/user_profile/presentation/pages/favorite_dorms_page.dart';
import 'package:findmydorm/features/user_profile/presentation/pages/account_settings_page.dart';
import 'package:findmydorm/features/dorms/presentation/pages/dorm_lists.dart';
import 'package:findmydorm/features/maps/presentation/pages/maps_detail_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Main router configuration for the application handling all navigation paths.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth-check',
      builder: (context, state) => const AuthCheckWrapper(),
    ),
    GoRoute(
      path: '/selection',
      builder: (context, state) => const SelectionPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final Users user = state.extra as Users;
        return HomeHolder(currentUser: user);
      },
    ),
    GoRoute(
      path: '/dorm-detail',
      builder: (context, state) {
        // We'll pass dorm via extra parameter or pass id.
        // For now, since extra can be dynamic, we just cast it.
        final Dorms dorm = state.extra as Dorms;
        return DormDetailPage(dorm);
      },
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) {
        final Users user = state.extra as Users;
        return FavoriteDormsPage(currentUser: user);
      },
    ),
    GoRoute(
      path: '/account-settings',
      builder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        final Users user = extra['user'] as Users;
        final ValueChanged<Users> onUserUpdated =
            extra['onUserUpdated'] as ValueChanged<Users>;
        return AccountSettingsPage(
          user: user,
          onUserUpdated: onUserUpdated,
        );
      },
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) {
        final Users user = state.extra as Users;
        return ChangePasswordPage(user: user);
      },
    ),
    GoRoute(
      path: '/dorm-list',
      builder: (context, state) {
        final String? initialQuery = state.extra as String?;
        return DormList(initialSearchQuery: initialQuery);
      },
    ),
    GoRoute(
      path: '/maps-detail',
      builder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return MapsDetailPage(
          latitude: extra['latitude'] as double,
          longitude: extra['longitude'] as double,
          dormName: extra['dormName'] as String,
          userLatitude: extra['userLatitude'] as double?,
          userLongitude: extra['userLongitude'] as double?,
        );
      },
    ),
  ],
);
