import 'package:flutter/material.dart';
import '../services/n8n_service.dart';

class DataManagementScreen extends StatefulWidget {
  @override
  _DataManagementScreenState createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  List<String> errores = [];
  final N8nService n8nService = N8nService();

  @override
  void initState() {
    super.initState();
    _cargarErrores();
  }

  void _cargarErrores() async {
    errores = await n8nService.obtenerErrores();
    setState(() {});
  }

  void _resolverError(String error) {
    // Lógica para resolver (e.g., restaurar)
    setState(() {
      errores.remove(error);
    });
    n8nService.resolverError(error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestión de Datos')),
      body: errores.isEmpty
          ? Center(child: Text('No hay errores detectados'))
          : ListView.builder(
              itemCount: errores.length,
              itemBuilder: (context, index) {
                String error = errores[index];
                return ListTile(
                  title: Text(error),
                  trailing: ElevatedButton(
                    onPressed: () => _resolverError(error),
                    child: Text('Resolver'),
                  ),
                );
              },
            ),
    );
  }
}