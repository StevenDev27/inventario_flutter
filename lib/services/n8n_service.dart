import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventario_pyme_flutter/models/producto.dart';

class N8nService {
  final String url = 'https://stevenpajarol1.app.n8n.cloud/webhook-test/inventario-pyme';

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
}