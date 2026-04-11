class InventarioMovimiento {
  final String idProducto;
  final int cantidad;
  final String tipo; // 'entrada' o 'salida'

  InventarioMovimiento({
    required this.idProducto,
    required this.cantidad,
    required this.tipo,
  });

  // Convierte el objeto a JSON para enviarlo a n8n
  Map<String, dynamic> toJson() => {
    'id_producto': idProducto,
    'cantidad': cantidad,
    'tipo': tipo,
  };
}