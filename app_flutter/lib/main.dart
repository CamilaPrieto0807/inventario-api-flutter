import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'services/product_api.dart';
import 'state/products_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final api = ProductApi(baseUrl: dotenv.env['API_BASE_URL'] ?? '');
  runApp(InventoryApp(store: ProductsStore(api)));
}
