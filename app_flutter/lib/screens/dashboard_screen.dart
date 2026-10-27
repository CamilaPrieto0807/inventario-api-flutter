import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) InventoryScope.of(context).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = InventoryScope.of(context);
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: r'$ ');
    return RefreshIndicator(
      onRefresh: store.refresh,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Resumen del inventario',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Indicadores actualizados desde la API.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          if (store.isLoading && store.products.isEmpty)
            const LinearProgressIndicator(),
          if (store.errorMessage != null) ...[
            _ErrorBanner(message: store.errorMessage!, onRetry: store.refresh),
            const SizedBox(height: 12),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth > 640
                  ? (constraints.maxWidth - 24) / 3
                  : (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricCard(
                    width: width,
                    icon: Icons.category_outlined,
                    label: 'Productos registrados',
                    value: '${store.products.length}',
                  ),
                  _MetricCard(
                    width: width,
                    icon: Icons.inventory_outlined,
                    label: 'Unidades disponibles',
                    value: '${store.totalUnits}',
                  ),
                  _MetricCard(
                    width: width,
                    icon: Icons.payments_outlined,
                    label: 'Valor del inventario',
                    value: currency.format(store.inventoryValue),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () => context.go('/products'),
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Gestionar productos'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 14),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.errorContainer,
    child: ListTile(
      leading: const Icon(Icons.error_outline),
      title: Text(message),
      trailing: IconButton(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        tooltip: 'Reintentar',
      ),
    ),
  );
}
