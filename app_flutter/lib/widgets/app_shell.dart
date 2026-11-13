import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = location.startsWith('/products')
        ? 1
        : location.startsWith('/session')
        ? 2
        : 0;
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.inventory_2_outlined),
            SizedBox(width: 10),
            Text('Inventario'),
          ],
        ),
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          context.go(const ['/dashboard', '/products', '/session'][index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Sesión',
          ),
        ],
      ),
    );
  }
}