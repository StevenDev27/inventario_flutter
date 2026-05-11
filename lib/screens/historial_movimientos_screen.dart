import 'package:flutter/material.dart';
import '../models/movimiento_historial.dart';
import '../services/historial_movimientos_service.dart';

class HistorialMovimientosScreen extends StatelessWidget {
  const HistorialMovimientosScreen({super.key});

  String _formatearFecha(DateTime fecha) {
    final day = fecha.day.toString().padLeft(2, '0');
    final month = fecha.month.toString().padLeft(2, '0');
    final year = fecha.year.toString();
    final hour = fecha.hour.toString().padLeft(2, '0');
    final minute = fecha.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Movimientos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Limpiar historial',
            onPressed: () {
              HistorialMovimientosService.limpiarHistorial();
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<MovimientoHistorial>>(
        valueListenable: HistorialMovimientosService.historialNotifier,
        builder: (context, historial, child) {
          if (historial.isEmpty) {
            return const Center(
              child: Text('Aun no hay movimientos registrados'),
            );
          }

          return ListView.separated(
            itemCount: historial.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final movimiento = historial[index];
              final esEntrada = movimiento.accion == 'entrada';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: esEntrada
                      ? Colors.green[100]
                      : Colors.red[100],
                  child: Icon(
                    esEntrada ? Icons.arrow_downward : Icons.arrow_upward,
                    color: esEntrada ? Colors.green[700] : Colors.red[700],
                  ),
                ),
                title: Text(movimiento.productoNombre),
                subtitle: Text(
                  'SKU: ${movimiento.sku}\n${_formatearFecha(movimiento.fecha)}',
                ),
                isThreeLine: true,
                trailing: Text(
                  '${esEntrada ? '+' : '-'}${movimiento.cantidad}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: esEntrada ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
