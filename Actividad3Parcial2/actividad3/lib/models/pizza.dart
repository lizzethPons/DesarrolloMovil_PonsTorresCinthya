class Pizza {
  final int? id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final String? categoria;
  final String? imagenUrl;

  Pizza({
    this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    this.categoria,
    this.imagenUrl,
  });

  factory Pizza.fromMap(Map<String, dynamic> m) => Pizza(
        id: m['id'] as int,
        nombre: (m['nombre'] ?? '') as String,
        descripcion: m['descripcion'] as String?,
        precio: (m['precio'] as num).toDouble(),
        categoria: m['categoria'] as String?,
        imagenUrl: m['imagen_url'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'categoria': categoria,
        'imagen_url': imagenUrl,
      };
}