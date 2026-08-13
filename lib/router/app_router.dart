import 'package:engez/features/auth/presentation/screens/loading_screen.dart';
import 'package:engez/features/auth/presentation/screens/login_screen.dart';
import 'package:engez/features/auth/presentation/screens/manage_menu_screen.dart';
import 'package:engez/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:engez/features/auth/presentation/screens/home_screen.dart';
import 'package:engez/features/auth/presentation/screens/all_places.dart';
import 'package:engez/features/auth/presentation/screens/place_details.dart';
import 'package:engez/features/cart/presentation/screens/cart_screen.dart';
import 'package:engez/features/auth/presentation/screens/profile.dart';
import 'package:engez/features/auth/presentation/screens/owner_dashboard_screen.dart';
import 'package:engez/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:engez/features/admin/presentation/screens/admin_requests_screen.dart';
import 'package:engez/features/auth/presentation/screens/add_edit_place_screen.dart';
import 'package:engez/features/order/presentation/screens/order_history_screen.dart';
import 'package:engez/features/order/presentation/screens/owner_orders_screen.dart';
import 'package:engez/models/place_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/loading',
    redirect: (context, state) async {
      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'all-places',
            builder: (context, state) => const AllPlaces(),
          ),
          GoRoute(
            path: 'place-details',
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
        ],
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
          // ✅ المسار الجديد لإدارة القائمة (تحت owner-dashboard)
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
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const Profile(),
      ),
      GoRoute(
        path: '/order-history',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/all-places',
        builder: (context, state) => const AllPlaces(),
      ),
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
            Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'الصفحة التي تبحث عنها غير موجودة',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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