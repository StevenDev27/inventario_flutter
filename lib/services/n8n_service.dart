import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';

class N8nService {
  // Reemplaza con tus URLs reales de n8n
  final String addProductUrl =
      'https://stevenpajarol2.app.n8n.cloud/webhook/agregar-producto'; // Webhook para agregar nuevo producto
  final String updateStockUrl =
      'https://stevenpajarol2.app.n8n.cloud/webhook/inventario-pyme'; // Webhook para actualizar stock (entrada/salida)
  final String getProductsUrl =
      'https://stevenpajarol2.app.n8n.cloud/webhook/obtener-datos'; // Webhook para obtener productos del Sheet

  Future<List<Producto>> obtenerProductos() async {
    try {
      final response = await http.get(Uri.parse(getProductsUrl));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> rows = _extractRows(body);
        return rows
            .map((json) => Producto.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Error al obtener productos: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback a datos simulados si falla
      await Future.delayed(Duration(seconds: 2));
      return [
        Producto(
          id: '1',
          nombre: 'Producto A',
          categoria: 'General',
          sku: 'SKU001',
          cantidad: 10,
          stockMinimo: 5,
          ultimaActualizacion: DateTime.now().toIso8601String(),
        ),
        Producto(
          id: '2',
          nombre: 'Producto B',
          categoria: 'General',
          sku: 'SKU002',
          cantidad: 5,
          stockMinimo: 2,
          ultimaActualizacion: DateTime.now().toIso8601String(),
        ),
      ];
    }
  }

  List<dynamic> _extractRows(dynamic body) {
    if (body is List) {
      return body;
    }
    if (body is Map<String, dynamic>) {
      if (body['data'] is List) return body['data'];
      if (body['rows'] is List) return body['rows'];
      if (body['products'] is List) return body['products'];
      for (final value in body.values) {
        if (value is List) return value;
      }
    }
    return [];
  }

  Future<void> actualizarProducto(Producto producto) async {
    try {
      final body = jsonEncode(producto.toJson());
      print('=================================');
      print('📤 ENVIANDO ACTUALIZACIÓN A N8N');
      print('URL: $updateStockUrl');
      print('PAYLOAD: $body');
      print('=================================');

      final response = await http.post(
        Uri.parse(updateStockUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('=================================');
      print('📥 RESPUESTA DE N8N');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=================================');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ ERROR EN ACTUALIZAR: $e');
      rethrow;
    }
  }

  Future<void> actualizarStock({
    required String id,
    required int cantidad,
    required String tipo,
  }) async {
    try {
      final payload = {'id': id, 'cantidad': cantidad, 'tipo': tipo};
      final body = jsonEncode(payload);
      print('=================================');
      print('📤 ENVIANDO MOVIMIENTO DE STOCK');
      print('URL: $updateStockUrl');
      print('PAYLOAD: $body');
      print('=================================');

      final response = await http.post(
        Uri.parse(updateStockUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('=================================');
      print('📥 RESPUESTA DE N8N');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=================================');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ ERROR EN ACTUALIZAR STOCK: $e');
      rethrow;
    }
  }

  Future<void> agregarProducto(Producto producto) async {
    try {
      final body = jsonEncode(producto.toJson());
      print('📤 Enviando nuevo producto a n8n: $body');

      final response = await http.post(
        Uri.parse(addProductUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('📥 Respuesta de n8n (${response.statusCode}): ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Error al agregar producto: ${response.statusCode}\nRespuesta: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error en agregarProducto: $e');
      rethrow;
    }
  }

  Future<void> eliminarProducto(String id) async {
    // Asumir que eliminar es actualizar cantidad a 0
    Producto prod = Producto(
      id: id,
      nombre: '',
      categoria: '',
      sku: '',
      cantidad: 0,
      stockMinimo: 0,
    );
    await actualizarProducto(prod);
  }

  Future<List<String>> obtenerErrores() async {
    // Simular o agregar webhook si es necesario
    return ['Fila borrada en Sheets: Producto X'];
  }

  Future<void> resolverError(String error) async {
    // Lógica para resolver, e.g., llamar a webhook de restauración
  }
}
