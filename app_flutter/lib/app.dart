import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/product_form_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/session_screen.dart';
import 'services/product_api.dart';
import 'state/auth_store.dart';
import 'state/products_store.dart';
import 'widgets/app_shell.dart';

class InventoryApp extends StatefulWidget {
  const InventoryApp({super.key, required this.store, required this.authStore});

  final ProductsStore store;
  final AuthStore authStore;

  @override
  State<InventoryApp> createState() => _InventoryAppState();
}

class _InventoryAppState extends State<InventoryApp> {
  late final GoRouter _router = GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: widget.authStore,
    // Sin sesión solo se puede ver /login; con sesión, /login redirige al dashboard
    redirect: (context, state) {
      final autenticado = widget.authStore.isAuthenticated;
      final enLogin = state.matchedLocation == '/login';
      if (!autenticado && !enLogin) return '/login';
      if (autenticado && enLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/session',
            builder: (context, state) => const SessionScreen(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const ProductFormScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    ProductDetailScreen(productId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => ProductFormScreen(
                      productId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('No fue posible abrir esta pantalla: ${state.error}'),
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    widget.authStore.addListener(_onAuthChanged);
  }

  // Al perder la sesión se limpian los productos en memoria
  void _onAuthChanged() {
    if (!widget.authStore.isAuthenticated) widget.store.clear();
  }

  @override
  void dispose() {
    widget.authStore.removeListener(_onAuthChanged);
    _router.dispose();
    widget.store.dispose();
    widget.authStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      notifier: widget.authStore,
      child: InventoryScope(
        notifier: widget.store,
        child: MaterialApp.router(
          title: 'Inventario',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF176B58),
              surface: const Color(0xFFF7F9F8),
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF7F9F8),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
          ),
          routerConfig: _router,
        ),
      ),
    );
  }
}

class InventoryScope extends InheritedNotifier<ProductsStore> {
  const InventoryScope({
    super.key,
    required ProductsStore notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ProductsStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<InventoryScope>();
    if (scope == null || scope.notifier == null) {
      throw StateError('InventoryScope no está disponible en este contexto');
    }
    return scope.notifier!;
  }
}

class AuthScope extends InheritedNotifier<AuthStore> {
  const AuthScope({
    super.key,
    required AuthStore notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AuthStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    if (scope == null || scope.notifier == null) {
      throw StateError('AuthScope no está disponible en este contexto');
    }
    return scope.notifier!;
  }
}

ProductApi productApiOf(BuildContext context) => InventoryScope.of(context).api;