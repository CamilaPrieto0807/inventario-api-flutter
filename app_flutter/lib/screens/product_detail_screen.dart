import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../models/product.dart';
import '../services/product_api.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product> _product;
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted) {
      _loadStarted = true;
      _product = _loadProduct();
    }
  }

  Future<Product> _loadProduct() =>
      productApiOf(context).getProduct(int.parse(widget.productId));

  Future<void> _edit() async {
    final changed = await context.push<bool>(
      '/products/${widget.productId}/edit',
    );
    if (changed == true && mounted) {
      setState(() => _product = _loadProduct());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado correctamente')),
      );
    }
  }

  Future<void> _delete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Deseas eliminar "${product.nombre}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await InventoryScope.of(context).delete(product.id!);
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        context.go('/products');
        messenger.showSnackBar(
          const SnackBar(content: Text('Producto eliminado correctamente')),
        );
      }
    } on ApiException catch (error) {
      if (mounted) _showError(error.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: r'$ ');
    return FutureBuilder<Product>(
      future: _product,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(snapshot.error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => setState(() => _product = _loadProduct()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }
        final product = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              product.nombre,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            _DetailRow(label: 'Código', value: product.codigo),
            _DetailRow(label: 'Categoría', value: product.categoria),
            _DetailRow(
              label: 'Descripción',
              value: product.descripcion?.isNotEmpty == true
                  ? product.descripcion!
                  : 'Sin descripción',
            ),
            _DetailRow(label: 'Precio', value: currency.format(product.precio)),
            _DetailRow(
              label: 'Cantidad disponible',
              value: '${product.cantidad}',
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _edit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar producto'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _delete(product),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Eliminar producto'),
            ),
          ],
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: Text(label, style: Theme.of(context).textTheme.labelLarge),
      subtitle: Text(value),
    ),
  );
}
