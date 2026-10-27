import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/product_api.dart';

class ProductsStore extends ChangeNotifier {
  ProductsStore(this.api);

  final ProductApi api;
  List<Product> products = [];
  bool isLoading = false;
  String? errorMessage;

  int get totalUnits =>
      products.fold(0, (total, product) => total + product.cantidad);

  double get inventoryValue => products.fold(
    0,
    (total, product) => total + product.precio * product.cantidad,
  );

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      products = await api.getProducts();
    } on ApiException catch (error) {
      errorMessage = error.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Product> create(Product product) async {
    final saved = await api.createProduct(product);
    products = [saved, ...products];
    notifyListeners();
    await refresh();
    return saved;
  }

  Future<Product> update(int id, Product product) async {
    final saved = await api.updateProduct(id, product);
    products = products.map((item) => item.id == id ? saved : item).toList();
    notifyListeners();
    await refresh();
    return saved;
  }

  Future<void> delete(int id) async {
    await api.deleteProduct(id);
    products = products.where((product) => product.id != id).toList();
    notifyListeners();
    await refresh();
  }
}
