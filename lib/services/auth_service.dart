import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Asegúrate de que no tenga una '/' al final aquí
  final String baseUrl = "https://soliz-francisco-taller-mecanico-api.desarrollo-software.xyz/api";

  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      // LA CORRECCIÓN ESTÁ AQUÍ: Agregamos /auth/ antes de login/
      final String fullUrl = "$baseUrl/auth/login/";
      
      debugPrint("Intentando conectar a: $fullUrl"); // Esto te ayudará a confirmar en la consola

      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      // Si sale 200, todo perfecto
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        // Si sale 404, 400 o 500, lo veremos aquí
        debugPrint("Error del servidor: ${response.statusCode}");
        debugPrint("Cuerpo del error: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error de red o conexión: $e");
    }
    return null;
  }
}