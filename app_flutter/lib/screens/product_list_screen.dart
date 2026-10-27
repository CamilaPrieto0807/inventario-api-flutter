import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../models/product.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
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
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await context.push<bool>('/products/new');
          if (created == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Producto registrado correctamente'),
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
      body: RefreshIndicator(
        onRefresh: store.refresh,
        child: store.isLoading && store.products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : store.errorMessage != null && store.products.isEmpty
            ? _LoadError(message: store.errorMessage!, onRetry: store.refresh)
            : store.products.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.inventory_2_outlined, size: 54),
                  Center(child: Text('Aún no hay productos registrados')),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: store.products.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final product = store.products[index];
                  return _ProductTile(
                    product: product,
                    price: currency.format(product.precio),
                  );
                },
              ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.price});

  final Product product;
  final String price;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(
        child: Text(product.nombre.characters.first.toUpperCase()),
      ),
      title: Text(product.nombre),
      subtitle: Text('$price  ·  ${product.cantidad} unidades'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/products/${product.id}'),
    ),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const Icon(Icons.cloud_off_outlined, size: 48),
      const SizedBox(height: 12),
      Center(child: Text(message, textAlign: TextAlign.center)),
      const SizedBox(height: 12),
      Center(
        child: OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      ),
    ],
  );
}
