import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';

class N8nService {
  final String url =
      'https://stevenpajarol1.app.n8n.cloud/webhook/inventario-pyme';

  Future<bool> enviarMovimiento(InventarioMovimiento movimiento) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(movimiento.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error conectando con n8n: $e");
      return false;
    }
  }

  Future<List<dynamic>> fetchProductos() async {
    // USA TU URL DE PRODUCCIÓN DE N8N (la de GET)
    final String url =
        'https://stevenpajarol1.app.n8n.cloud/webhook/obtener-datos';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded;
        }

        if (decoded is Map<String, dynamic>) {
          return [decoded];
        }

        return [];
      } else {
        throw Exception('Error al cargar productos');
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
}
