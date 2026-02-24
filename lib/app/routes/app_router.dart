import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/widgets/app_shell.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/product/product_detail_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/wishlist/wishlist_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/addresses_screen.dart';
import '../../presentation/screens/profile/orders_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/home/category_screen.dart';
import '../../presentation/screens/profile/help_support_screen.dart';
import '../../presentation/screens/profile/settings_screen.dart';
import '../../presentation/screens/checkout/checkout_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Main shell with bottom nav
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Home tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const HomeScreen(),
                  transitionsBuilder: _fadeTransition,
                ),
                routes: [
                  GoRoute(
                    path: 'category/:name',
                    pageBuilder: (context, state) {
                      final name = Uri.decodeComponent(
                          state.pathParameters['name'] ?? '');
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: CategoryScreen(category: name),
                        transitionsBuilder: _slideTransition,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'product/:id',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: ProductDetailScreen(productId: id),
                        transitionsBuilder: _fadeTransition,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // Wishlist tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wishlist',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const WishlistScreen(),
                  transitionsBuilder: _fadeTransition,
                ),
              ),
            ],
          ),
          // Cart tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const CartScreen(),
                  transitionsBuilder: _fadeTransition,
                ),
              ),
            ],
          ),
          // Profile tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const ProfileScreen(),
                  transitionsBuilder: _fadeTransition,
                ),
                routes: [
                  GoRoute(
                    path: 'addresses',
                    pageBuilder: (context, state) {
                      final isSelection = state.uri.queryParameters['selection'] == 'true';
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: AddressesScreen(isSelectionMode: isSelection),
                        transitionsBuilder: _slideTransition,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'orders',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      child: const OrdersScreen(),
                      transitionsBuilder: _slideTransition,
                    ),
                  ),
                  GoRoute(
                    path: 'help-support',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      child: const HelpSupportScreen(),
                      transitionsBuilder: _slideTransition,
                    ),
                  ),
                  GoRoute(
                    path: 'settings',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      child: const SettingsScreen(),
                      transitionsBuilder: _slideTransition,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/checkout',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CheckoutScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: '/select-address',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddressesScreen(isSelectionMode: true),
          transitionsBuilder: _slideTransition,
        ),
      ),
      // Auth routes (outside shell - no bottom nav)
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: '/signup',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignUpScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
    ],
  );
}

Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
    child: child,
  );
}

Widget _slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
    child: FadeTransition(opacity: animation, child: child),
  );
}
