import 'package:app_flutter/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('converts an API product to and from JSON', () {
    final product = Product.fromJson({
      'id': 12,
      'nombre': 'Café',
      'codigo': 'CAF-01',
      'descripcion': null,
      'precio': '9500.00',
      'cantidad': 8,
      'categoria': 'Bebidas',
    });

    expect(product.id, 12);
    expect(product.precio, 9500);
    expect(product.cantidad, 8);
    expect(product.toJson(), {
      'nombre': 'Café',
      'codigo': 'CAF-01',
      'descripcion': null,
      'precio': 9500,
      'cantidad': 8,
      'categoria': 'Bebidas',
    });
  });
}
