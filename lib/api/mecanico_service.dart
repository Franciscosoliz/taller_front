import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MecanicoService {
  // URL REAL DE TU API
  final String baseUrl =
      "https://soliz-francisco-taller-mecanico-api.desarrollo-software.xyz/api";

  // FUNCIÓN PARA CREAR MECÁNICO (POST)
  Future<bool> crearMecanico(Map<String, dynamic> datosMecanico) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mecanicos/'), // Endpoint corregido según tu lista
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(datosMecanico),
      );

      // Django REST suele devolver 201 para creación
      return response.statusCode == 201;
    } catch (e) {
      debugPrint("Error de conexión al crear mecánico: $e");
      return false;
    }
  }

  // FUNCIÓN PARA OBTENER MECÁNICOS (GET)
  Future<List<dynamic>> fetchMecanicos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/mecanicos/'));

      if (response.statusCode == 200) {
        // Usamos utf8.decode para evitar problemas con tildes o la "ñ"
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error al obtener mecánicos: $e");
      return [];
    }
  }

  // AGREGAMOS: FUNCIÓN PARA ELIMINAR (DELETE)
  Future<bool> eliminarMecanico(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/mecanicos/$id/'));
      return response.statusCode == 204; // 204 significa eliminado con éxito
    } catch (e) {
      debugPrint("Error al eliminar: $e");
      return false;
    }
  }

  // --- NUEVA FUNCIÓN PARA AGENDAR CITAS ---
  Future<bool> crearCita(Map<String, dynamic> datosCita) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/citas/',
        ), // Verifica si el endpoint es /citas/ o /appointments/
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(datosCita),
      );

      // Si Django devuelve 201 Created, la cita se guardó
      if (response.statusCode == 201) {
        debugPrint("Cita V8 creada con éxito");
        return true;
      } else {
        debugPrint("Error del servidor: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error de conexión al agendar cita: $e");
      return false;
    }
  }

  Future<List<dynamic>> fetchOrdenes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ordenes/'));

      if (response.statusCode == 200) {
        // Decodificamos el cuerpo de la respuesta
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        // Según tu JSON, la lista real de órdenes está en la llave 'results'
        if (data.containsKey('results')) {
          return data['results'];
        }
        return [];
      } else {
        debugPrint("Error en el servidor: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Error de conexión al obtener órdenes: $e");
      return [];
    }
  }
}
