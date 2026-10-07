class Sucursal {
  final int? id;
  final String nombre;
  final String direccion;
  final double latitud;
  final double longitud;
  final String? telefono;

  Sucursal({
    this.id,
    required this.nombre,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    this.telefono,
  });

  factory Sucursal.fromMap(Map<String, dynamic> m) => Sucursal(
        id: m['id'] as int,
        nombre: (m['nombre'] ?? '') as String,
        direccion: (m['direccion'] ?? '') as String,
        latitud: (m['latitud'] as num).toDouble(),
        longitud: (m['longitud'] as num).toDouble(),
        telefono: m['telefono'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'direccion': direccion,
        'latitud': latitud,
        'longitud': longitud,
        'telefono': telefono,
      };
}