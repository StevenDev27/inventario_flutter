import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/n8n_service.dart';
import 'historial_movimientos_screen.dart';
import 'movimiento_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Producto> productos = [];
  List<Producto> productosFiltrados = [];
  TextEditingController searchController = TextEditingController();
  bool isSincronizando = false;
  final N8nService n8nService = N8nService();

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    searchController.addListener(_filtrarProductos);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filtrarProductos() {
    String query = searchController.text.toLowerCase();
    setState(() {
      productosFiltrados = productos
          .where(
            (p) =>
                p.nombre.toLowerCase().contains(query) ||
                p.sku.toLowerCase().contains(query),
          )
          .toList();
    });
  }

  Future<void> _cargarProductos() async {
    // Cargar productos desde Sheets vía n8n
    setState(() => isSincronizando = true);
    productos = await n8nService.obtenerProductos();
    productos.sort((a, b) => a.idNumeric.compareTo(b.idNumeric));
    productosFiltrados = List.from(productos);
    if (mounted) setState(() => isSincronizando = false);
  }

  void _agregarProducto() async {
    TextEditingController nombreController = TextEditingController();
    TextEditingController categoriaController = TextEditingController();
    TextEditingController skuController = TextEditingController();
    TextEditingController cantidadController = TextEditingController();
    TextEditingController stockMinimoController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nuevo Producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: categoriaController,
                decoration: InputDecoration(labelText: 'Categoría'),
              ),
              TextField(
                controller: skuController,
                decoration: InputDecoration(labelText: 'SKU'),
              ),
              TextField(
                controller: cantidadController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Cantidad Inicial'),
              ),
              TextField(
                controller: stockMinimoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Stock Mínimo'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              String nombre = nombreController.text;
              String categoria = categoriaController.text;
              String sku = skuController.text;
              int cantidad = int.tryParse(cantidadController.text) ?? 0;
              int stockMinimo = int.tryParse(stockMinimoController.text) ?? 0;
              if (nombre.isNotEmpty && sku.isNotEmpty) {
                Producto nuevo = Producto(
                  id: _getNextId().toString(),
                  nombre: nombre,
                  categoria: categoria.isNotEmpty ? categoria : 'General',
                  sku: sku,
                  cantidad: cantidad,
                  stockMinimo: stockMinimo,
                  ultimaActualizacion: DateTime.now().toIso8601String(),
                );
                setState(() => isSincronizando = true);
                try {
                  await n8nService.agregarProducto(nuevo);
                  if (mounted) setState(() => isSincronizando = false);
                  _cargarProductos(); // Recargar lista
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Producto agregado')));
                } catch (error) {
                  if (mounted) setState(() => isSincronizando = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al agregar producto: $error'),
                    ),
                  );
                }
              }
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  int _getNextId() {
    if (productos.isEmpty) return 1;
    final ids = productos
        .map((p) => p.idNumeric)
        .where((value) => value > 0)
        .toList();
    if (ids.isEmpty) return 1;
    return ids.reduce((a, b) => a > b ? a : b) + 1;
  }

  Color _stockColor(Producto producto) {
    final diferencia = producto.cantidad - producto.stockMinimo;
    if (diferencia < 0) return Colors.red;
    if (diferencia <= 10) return Colors.amber;
    return Colors.green;
  }

  String _stockLabel(Producto producto) {
    final diferencia = producto.cantidad - producto.stockMinimo;
    if (diferencia < 0) return '¡Bajo stock!';
    if (diferencia <= 10) return 'Stock por agotarse';
    return 'Stock saludable';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventario PYME'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _agregarProducto,
            tooltip: 'Agregar Producto',
          ),
          IconButton(
            icon: Icon(
              isSincronizando ? Icons.sync : Icons.sync_disabled,
              color: isSincronizando ? Colors.yellow : Colors.green,
            ),
            onPressed: _cargarProductos,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por Nombre o SKU',
                prefixIcon: Icon(Icons.search, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: isSincronizando && productosFiltrados.isEmpty
                ? Center(child: CircularProgressIndicator())
                : productosFiltrados.isEmpty
                ? Center(
                    child: Text(
                      'No hay productos para mostrar',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      print('👆 Actualizando manualmente (Pull-to-Refresh)...');
                      await _cargarProductos();
                    },
                    child: ListView.builder(
                      itemCount: productosFiltrados.length,
                      itemBuilder: (context, index) {
                        Producto prod = productosFiltrados[index];
                        return Dismissible(
                          key: ValueKey('${prod.id}_${prod.sku}_$index'),
                          direction: DismissDirection.horizontal,
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              // Eliminar
                              setState(() {
                                productos.remove(prod);
                                productosFiltrados.remove(prod);
                              });
                              n8nService.eliminarProducto(prod.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Producto eliminado')),
                              );
                            }
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.delete),
                          ),
                          secondaryBackground: Container(
                            color: Colors.blue,
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.edit),
                          ),
                          child: ListTile(
                            title: Text(
                              prod.nombre,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SKU: ${prod.sku}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'monospace',
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Categoría: ${prod.categoria} | Mín: ${prod.stockMinimo}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${prod.cantidad}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _stockColor(prod),
                                  ),
                                ),
                                Text(
                                  _stockLabel(prod),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _stockColor(prod),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () =>
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MovimientoScreen(producto: prod),
                                  ),
                                ).then((updated) {
                                  if (updated == true && mounted) {
                                    print(
                                      '↩️ Volviendo de movimiento - recargando datos del Sheet',
                                    );
                                    _cargarProductos();
                                  }
                                }),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Total: ${productos.length}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Alertas: ${productos.where((p) => p.cantidad < p.stockMinimo).length}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistorialMovimientosScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}
