import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/onboarding/presentation/screens/loading_screen.dart';
import 'package:engez/features/auth/presentation/screens/login_screen.dart';
import 'package:engez/features/menu/presentation/screens/manage_menu_screen.dart';
import 'package:engez/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:engez/features/home/presentation/screens/home_screen.dart';
import 'package:engez/features/place/presentation/screens/all_places.dart';
import 'package:engez/features/place/presentation/screens/place_details.dart';
import 'package:engez/features/cart/presentation/screens/cart_screen.dart';
import 'package:engez/features/profile/presentation/screens/profile.dart';
import 'package:engez/features/owner/presentation/screens/owner_dashboard_screen.dart';
import 'package:engez/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:engez/features/admin/presentation/screens/admin_requests_screen.dart';
import 'package:engez/features/place/presentation/screens/add_edit_place_screen.dart';
import 'package:engez/features/order/presentation/screens/order_history_screen.dart';
import 'package:engez/features/order/presentation/screens/order_tracking_screen.dart';
import 'package:engez/features/order/presentation/screens/owner_orders_screen.dart';
import 'package:engez/models/place_model.dart';
import 'package:engez/widgets/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:engez/core/managers/auth_manager.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/loading',
    refreshListenable: authManager,
    redirect: (context, state) {
      final authStatus = authManager.status;
      final role = authManager.role;
      final path = state.matchedLocation;

      // Allow loading screen to resolve without redirecting elsewhere
      if (authStatus == AuthStatus.loading || authStatus == AuthStatus.initial) {
        if (path == '/loading') return null; // already on loading
        return '/loading';
      }

      // If user is totally unauthenticated
      if (authStatus == AuthStatus.unauthenticated) {
        if (path == '/login') return null; // let them login
        return '/login'; // kick them to login
      }

      // At this point, user IS authenticated.
      // If role is null, force role selection unless they are already there or logging out
      if (role == null || role.isEmpty) {
        if (path == '/role-selection' || path == '/login') return null;
        return '/role-selection';
      }

      // Check role-based guards
      if (path.startsWith('/owner-dashboard')) {
        if (role != 'owner') return '/home'; // unauthorized
      }

      if (path.startsWith('/admin-dashboard') || path.startsWith('/admin-requests')) {
        if (role != 'admin') return '/home'; // unauthorized
      }

      // If authenticated and tries to go to login or loading, send them to their dashboard
      if (path == '/login' || path == '/loading') {
        if (role == 'owner') return '/owner-dashboard';
        if (role == 'admin') return '/admin-dashboard';
        return '/home'; // default for customer
      }

      return null; // All good, proceed
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/order-tracking/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrderTrackingScreen(orderId: id);
        },
      ),
      
      // The StatefulShellRoute for the bottom navigation bar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
            ),
          );
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 1: Search (All Places)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/all-places',
                builder: (context, state) => const AllPlaces(),
              ),
            ],
          ),
          // Branch 2: Orders
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/order-history',
                builder: (context, state) => const OrderHistoryScreen(),
              ),
            ],
          ),
          // Branch 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const Profile(),
              ),
            ],
          ),
        ],
      ),

      // Routes OUTSIDE the shell (bottom nav bar is hidden)
      GoRoute(
        path: '/place-details',
        builder: (context, state) {
          final place = state.extra as Place?;
          if (place == null) {
            return const Scaffold(
              body: Center(child: Text('لم يتم العثور على المكان')),
            );
          }
          return PlaceDetailsScreen(place: place);
        },
      ),
      GoRoute(
        path: '/cart', 
        builder: (context, state) => const CartScreen()
      ),
      GoRoute(
        path: '/owner-dashboard',
        builder: (context, state) => const OwnerDashboardScreen(),
        routes: [
          GoRoute(
            path: 'add-place',
            builder: (context, state) => const AddEditPlaceScreen(),
          ),
          GoRoute(
            path: 'edit-place',
            builder: (context, state) {
              final place = state.extra as Place?;
              return AddEditPlaceScreen(place: place);
            },
          ),
          GoRoute(
            path: 'manage-menu',
            builder: (context, state) {
              final place = state.extra as Place?;
              if (place == null) {
                return const Scaffold(
                  body: Center(child: Text('المكان غير موجود')),
                );
              }
              return ManageMenuScreen(place: place);
            },
          ),
          GoRoute(
            path: 'orders',
            builder: (context, state) {
              final place = state.extra as Place?;
              if (place == null) {
                return const Scaffold(
                  body: Center(child: Text('المكان غير موجود')),
                );
              }
              return OwnerOrdersScreen(place: place);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/owner-profile',
        builder: (context, state) => const Profile(),
      ),
      GoRoute(
        path: '/add-edit-place',
        builder: (context, state) {
          final place = state.extra as Place?;
          return AddEditPlaceScreen(place: place);
        },
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/requests',
        builder: (context, state) => const AdminRequestsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('صفحة غير موجودة')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: MyColors.myBorder),
            const SizedBox(height: 16),
            Text(
              'الصفحة التي تبحث عنها غير موجودة',
              style: TextStyle(fontSize: 18, color: MyColors.myTextSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );
}
