import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/email_verify_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/chat/screens/messages_list_screen.dart';
import '../features/bookmarks/screens/bookmarks_screen.dart';
import '../features/discovery/screens/partner_finder_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/ideas/screens/idea_detail_screen.dart';
import '../features/ideas/screens/idea_feed_screen.dart';
import '../features/ideas/screens/post_idea_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/my_profile_screen.dart';
import '../features/profile/screens/student_profile_screen.dart';
import '../features/requests/screens/my_partner_screen.dart';
import '../features/requests/screens/requests_list_screen.dart';
import '../features/requests/screens/send_request_screen.dart';
import '../features/settings/screens/settings_screen.dart';

final mockAuthProvider = StateProvider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(mockAuthProvider);
  const authRoutes = <String>{
    '/',
    '/login',
    '/signup',
    '/verify-email',
    '/forgot-password',
  };

  return GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final String location = state.matchedLocation;
      if (location == '/') {
        return isLoggedIn ? '/home' : '/login';
      }
      if (!isLoggedIn && !authRoutes.contains(location)) {
        return '/login';
      }
      if (isLoggedIn && authRoutes.contains(location)) {
        return '/home';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (BuildContext context, GoRouterState state) {
          return const SignupScreen();
        },
      ),
      GoRoute(
        path: '/verify-email',
        builder: (BuildContext context, GoRouterState state) {
          return const EmailVerifyScreen();
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (BuildContext context, GoRouterState state) {
          return const ForgotPasswordScreen();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/profile/me',
        builder: (BuildContext context, GoRouterState state) {
          return const MyProfileScreen();
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (BuildContext context, GoRouterState state) {
          return const EditProfileScreen();
        },
      ),
      GoRoute(
        path: '/profile/:userId',
        builder: (BuildContext context, GoRouterState state) {
          return StudentProfileScreen(
            userId: state.pathParameters['userId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/finder',
        builder: (BuildContext context, GoRouterState state) {
          return const PartnerFinderScreen();
        },
      ),
      GoRoute(
        path: '/send-request/:userId',
        builder: (BuildContext context, GoRouterState state) {
          return SendRequestScreen(
            userId: state.pathParameters['userId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/requests',
        builder: (BuildContext context, GoRouterState state) {
          return const RequestsListScreen();
        },
      ),
      GoRoute(
        path: '/my-partner',
        builder: (BuildContext context, GoRouterState state) {
          return const MyPartnerScreen();
        },
      ),
      GoRoute(
        path: '/ideas',
        builder: (BuildContext context, GoRouterState state) {
          return const IdeaFeedScreen();
        },
      ),
      GoRoute(
        path: '/post-idea',
        builder: (BuildContext context, GoRouterState state) {
          return const PostIdeaScreen();
        },
      ),
      GoRoute(
        path: '/idea/:ideaId',
        builder: (BuildContext context, GoRouterState state) {
          return IdeaDetailScreen(
            ideaId: state.pathParameters['ideaId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/messages',
        builder: (BuildContext context, GoRouterState state) {
          return const MessagesListScreen();
        },
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (BuildContext context, GoRouterState state) {
          return ChatScreen(
            chatId: state.pathParameters['chatId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/bookmarks',
        builder: (BuildContext context, GoRouterState state) {
          return const BookmarksScreen();
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsScreen();
        },
      ),
    ],
  );
});
