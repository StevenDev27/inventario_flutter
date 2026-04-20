import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/n8n_service.dart';

class MovimientoScreen extends StatefulWidget {
  final Producto? producto;

  const MovimientoScreen({super.key, this.producto});

  @override
  _MovimientoScreenState createState() => _MovimientoScreenState();
}

class _MovimientoScreenState extends State<MovimientoScreen> {
  TextEditingController cantidadController = TextEditingController();
  final N8nService n8nService = N8nService();
  bool isSincronizando = false;

  @override
  void initState() {
    super.initState();
    cantidadController.text = '';
  }

  void _guardarMovimiento(bool esEntrada) async {
    int cantidad = int.tryParse(cantidadController.text) ?? 0;
    if (widget.producto == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ingresa una cantidad válida'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ❌ VALIDAR: No permitir salida mayor al stock disponible
    if (!esEntrada && cantidad > widget.producto!.cantidad) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Operación no válida: No hay suficiente stock. Disponible: ${widget.producto!.cantidad}, solicitado: $cantidad',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final int originalCantidad = widget.producto!.cantidad;
    setState(() => isSincronizando = true);
    setState(() {
      widget.producto!.cantidad += esEntrada ? cantidad : -cantidad;
      widget.producto!.ultimaActualizacion = DateTime.now().toIso8601String();
    });

    try {
      // Enviar solo los campos que n8n espera
      await n8nService.actualizarStock(
        id: widget.producto!.id,
        cantidad: cantidad,
        tipo: esEntrada ? 'entrada' : 'salida',
      );
      setState(() => isSincronizando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(esEntrada ? 'Entrada registrada' : 'Salida registrada')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        widget.producto!.cantidad = originalCantidad;
        isSincronizando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar stock: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.producto != null ? '${widget.producto!.nombre}' : 'Movimiento'),
        backgroundColor: Colors.blue,
        elevation: 2,
        actions: [
          if (isSincronizando) Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.producto != null) ...[  
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('SKU: ${widget.producto!.sku}', style: TextStyle(fontSize: 16, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Text('Stock Actual: ${widget.producto!.cantidad}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                      SizedBox(height: 8),
                      Text('Mínimo: ${widget.producto!.stockMinimo}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 20),
            SizedBox(height: 20),
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Cantidad a mover',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            SizedBox(height: 20),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _guardarMovimiento(true),
                  icon: Icon(Icons.add_circle, size: 24),
                  label: Text('ENTRADA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(130, 56),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _guardarMovimiento(false),
                  icon: Icon(Icons.remove_circle, size: 24),
                  label: Text('SALIDA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(130, 56),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}