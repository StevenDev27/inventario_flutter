class Producto {
  String id;
  String nombre;
  String categoria;
  String sku;
  int cantidad;
  int stockMinimo;
  String ultimaActualizacion;
  bool sincronizado; // Para estados optimistas

  Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.sku,
    required this.cantidad,
    required this.stockMinimo,
    this.ultimaActualizacion = '',
    this.sincronizado = false,
  });

  int get idNumeric {
    return int.tryParse(id) ?? 0;
  }

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id']?.toString() ?? '0',
      nombre: json['nombre']?.toString() ?? '',
      categoria: json['categoria']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      cantidad: _parseInt(json['stock'] ?? json['cantidad']),
      stockMinimo: _parseInt(json['stock_minimo']),
      ultimaActualizacion: json['ultima_actualizacion']?.toString() ?? '',
      sincronizado: json['sincronizado'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'sku': sku,
      'stock': cantidad,
      'stock_minimo': stockMinimo,
      'ultima_actualizacion': ultimaActualizacion.isEmpty ? DateTime.now().toIso8601String() : ultimaActualizacion,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}