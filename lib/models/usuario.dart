class Usuario {
  final String id;
  final String nombre;
  final String email;
  final bool isStaff; // Este define si es Francisco (Admin) o Cliente

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.isStaff,
  });

  // Mapeo de JSON a objeto Dart
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? 'Técnico V8',
      email: json['email'] ?? '',
      // Mapeamos 'is_staff' de la base de datos al booleano isStaff
      isStaff: json['is_staff'] == true || json['is_staff'] == 1,
    );
  }
}