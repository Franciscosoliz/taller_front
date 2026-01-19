import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // --- ESTO ES NUEVO: Patrón Singleton ---
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  // ---------------------------------------

  final String baseUrl =
      "https://soliz-francisco-taller-mecanico-api.desarrollo-software.xyz/api";
  String? token; // Aquí se guardará tu llave

  // Función para capturar el token desde el Login
  void setToken(String newToken) {
    token = newToken;
    debugPrint("Token guardado en ApiService: $token");
  }

  // Modifica tus headers en todos los métodos para que usen el token
  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
    if (token != null) "Authorization": "Token $token",
  };

  Future<List<dynamic>> getTable(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$endpoint/"),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        if (decodedData is Map<String, dynamic> &&
            decodedData.containsKey('results')) {
          return decodedData['results'] as List<dynamic>;
        }
        return decodedData is List ? decodedData : [];
      }
    } catch (e) {
      debugPrint("Error en getTable: $e");
    }
    return [];
  }

  Future<bool> createRecord(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/$endpoint/"),
        headers: _headers,
        body: json.encode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint("Error en create: $e");
      return false;
    }
  }

  Future<bool> updateRecord(
    String endpoint,
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse("$baseUrl/$endpoint/$id/");
      final response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      debugPrint("Error Django ${response.statusCode}: ${response.body}");
      return false;
    } catch (e) {
      debugPrint("Error de red: $e");
      return false;
    }
  }

  Future<bool> deleteRecord(String endpoint, int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$endpoint/$id/"),
        headers: _headers,
      );
      return response.statusCode == 204;
    } catch (e) {
      debugPrint("Error en delete: $e");
      return false;
    }
  }
}
