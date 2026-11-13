import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'services/api_client.dart';
import 'services/auth_api.dart';
import 'services/auth_storage.dart';
import 'services/product_api.dart';
import 'state/auth_store.dart';
import 'state/products_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  if (baseUrl.trim().isEmpty) {
    throw const ApiException('Configura API_BASE_URL en el archivo .env');
  }

  final storage = AuthStorage();
  late final AuthStore authStore;
  final dio = createDio(
    baseUrl: baseUrl,
    storage: storage,
    onUnauthorized: () => authStore.sessionExpired(),
  );
  authStore = AuthStore(AuthApi(dio), storage);

  // Recupera y valida la sesión guardada antes de mostrar la app
  await authStore.init();

  runApp(
    InventoryApp(store: ProductsStore(ProductApi(dio)), authStore: authStore),
  );
}