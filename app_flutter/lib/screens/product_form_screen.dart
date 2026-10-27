import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../models/product.dart';
import '../services/product_api.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _quantity = TextEditingController();
  final _category = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;
  bool _loadStarted = false;
  String? _loadError;

  bool get _isEditing => widget.productId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isEditing && !_loadStarted) {
      _loadStarted = true;
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    try {
      final product = await productApiOf(context)
          .getProduct(int.parse(widget.productId!));
      _name.text = product.nombre;
      _code.text = product.codigo;
      _description.text = product.descripcion ?? '';
      _price.text = product.precio.toString();
      _quantity.text = product.cantidad.toString();
      _category.text = product.categoria;
    } on ApiException catch (error) {
      _loadError = error.message;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _description.dispose();
    _price.dispose();
    _quantity.dispose();
    _category.dispose();
    super.dispose();
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? 'Este campo es obligatorio'
      : null;

  String? _validPrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El precio es obligatorio';
    }
    final number = double.tryParse(value);
    if (number == null || !number.isFinite || number < 0) {
      return 'Ingresa un precio válido (mayor o igual a 0)';
    }
    return null;
  }

  String? _validQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La cantidad es obligatoria';
    }
    final number = int.tryParse(value);
    if (number == null || number < 0) {
      return 'Ingresa un entero mayor o igual a 0';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final product = Product(
      nombre: _name.text.trim(),
      codigo: _code.text.trim(),
      descripcion: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      precio: double.parse(_price.text.trim()),
      cantidad: int.parse(_quantity.text.trim()),
      categoria: _category.text.trim(),
    );
    try {
      if (_isEditing) {
        await InventoryScope.of(context)
            .update(int.parse(widget.productId!), product);
      } else {
        await InventoryScope.of(context).create(product);
      }
      if (mounted) context.pop(true);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: r'$ ');
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _loadError != null
        ? Center(child: Text(_loadError!))
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  _isEditing ? 'Editar producto' : 'Registrar producto',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                _input(_name, 'Nombre', validator: _required),
                _input(_code, 'Código', validator: _required),
                _input(_category, 'Categoría', validator: _required),
                _input(_description, 'Descripción (opcional)', maxLines: 3),
                _input(
                  _price,
                  'Precio (${currency.currencySymbol.trim()})',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _validPrice,
                ),
                _input(
                  _quantity,
                  'Cantidad',
                  keyboardType: TextInputType.number,
                  validator: _validQuantity,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Guardar cambios' : 'Registrar'),
                ),
              ],
            ),
          );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    ),
  );
}
