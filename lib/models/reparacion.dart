class Reparacion {
  final int id;
  final String pieza;
  final double progreso;
  final String estado;
  final bool completado;
  final String placa;

  Reparacion({
    required this.id,
    required this.pieza,
    required this.progreso,
    required this.estado,
    required this.completado,
    required this.placa,
  });

  factory Reparacion.fromJson(Map<String, dynamic> json) {
    return Reparacion(
      id: json['id_detalle'] ?? 0,
      pieza: json['servicio_nombre'] ?? 'Servicio General',
      progreso: (json['estado'] == 'completado') ? 1.0 : 0.5, // Lógica simple basada en estado
      estado: json['estado'] ?? 'EN PROCESO',
      completado: json['estado'] == 'completado',
      placa: json['vehiculo_placa'] ?? 'S/N', // Viene de la orden
    );
  }
}