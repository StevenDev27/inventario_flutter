import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/n8n_service.dart';

class MovimientoScreen extends StatefulWidget {
  const MovimientoScreen({super.key});

  @override
  _MovimientoScreenState createState() => _MovimientoScreenState();
}

class _MovimientoScreenState extends State<MovimientoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _cantidadController = TextEditingController();
  String _tipoMovimiento = 'entrada'; // Valor por defecto
  bool _isLoading = false;

  final N8nService _n8nService = N8nService();

  void _enviarDatos() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final movimiento = InventarioMovimiento(
        idProducto: _idController.text,
        cantidad: int.parse(_cantidadController.text),
        tipo: _tipoMovimiento,
      );

      bool exito = await _n8nService.enviarMovimiento(movimiento);

      setState(() => _isLoading = false);

      if (exito) {
        _idController.clear();
        _cantidadController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Movimiento registrado y n8n activado'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al conectar con el servidor'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SEGED - Control de Inventario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Registrar Entrada/Salida', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(labelText: 'ID del Producto (ej: P001)', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Ingresa el ID' : null,
              ),
              SizedBox(height: 15),
              
              TextFormField(
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Ingresa una cantidad' : null,
              ),
              SizedBox(height: 15),
              
              DropdownButtonFormField<String>(
                initialValue: _tipoMovimiento,
                decoration: InputDecoration(labelText: 'Tipo de Movimiento', border: OutlineInputBorder()),
                items: [
                  DropdownMenuItem(value: 'entrada', child: Text('Entrada (+)')),
                  DropdownMenuItem(value: 'salida', child: Text('Salida (-)')),
                ],
                onChanged: (value) => setState(() => _tipoMovimiento = value!),
              ),
              SizedBox(height: 30),

              // Botón con estado de carga
              ElevatedButton(
                onPressed: _isLoading ? null : _enviarDatos,
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 15)),
                child: _isLoading 
                  ? CircularProgressIndicator(color: Colors.white) 
                  : Text('REGISTRAR EN N8N', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}