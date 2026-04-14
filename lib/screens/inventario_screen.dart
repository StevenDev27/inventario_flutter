import 'package:flutter/material.dart';
import '../services/n8n_service.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  _InventarioScreenState createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final N8nService service = N8nService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inventario SEGED")),
      body: FutureBuilder<List<dynamic>>(
        future: service.fetchProductos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error al conectar con el servidor"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hay productos registrados"));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Nombre')),
                  DataColumn(label: Text('Categoría')),
                  DataColumn(label: Text('Stock Actual')),
                  DataColumn(label: Text('Stock Mínimo')),
                  DataColumn(label: Text('Última Actualización')),
                ],
                rows: snapshot.data!.map((producto) {
                  return DataRow(
                    cells: [
                      DataCell(Text(producto['id_producto'].toString())),
                      DataCell(Text(producto['nombre'].toString())),
                      DataCell(Text(producto['categoria'].toString())),
                      DataCell(Text(producto['stock_actual'].toString())),
                      DataCell(Text(producto['stock_minimo'].toString())),
                      DataCell(Text(producto['ultima_actualizacion'].toString())),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}