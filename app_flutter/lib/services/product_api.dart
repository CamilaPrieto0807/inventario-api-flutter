import 'package:dio/dio.dart';

import '../models/product.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProductApi {
  ProductApi(this._dio);

  final Dio _dio;

  Future<List<Product>> getProducts() async {
    final response = await _request(() => _dio.get('productos'));
    return (response.data as List<dynamic>)
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Product> getProduct(int id) async {
    final response = await _request(() => _dio.get('productos/$id'));
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> createProduct(Product product) async {
    final response = await _request(
      () => _dio.post('productos', data: product.toJson()),
    );
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> updateProduct(int id, Product product) async {
    final response = await _request(
      () => _dio.put('productos/$id', data: product.toJson()),
    );
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteProduct(int id) async {
    await _request(() => _dio.delete('productos/$id'));
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final errors = data['errors'];
        if (errors is Map<String, dynamic> && errors.isNotEmpty) {
          throw ApiException(errors.values.first.toString());
        }
        if (data['message'] is String) {
          throw ApiException(data['message'] as String);
        }
      }
      if (error.response == null) {
        throw const ApiException(
          'No se pudo conectar con la API. Verifica la URL y que el servidor esté activo.',
        );
      }
      throw ApiException('Error HTTP ${error.response?.statusCode ?? ''}');
    } on FormatException {
      throw const ApiException('La API devolvió una respuesta inválida');
    }
  }
}
