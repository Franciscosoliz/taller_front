import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart'; // <--- IMPORTANTE: Asegúrate de que esta ruta sea correcta

class AuthProvider with ChangeNotifier {
  Usuario? _user;

  final String _baseUrl =
      "https://soliz-francisco-taller-mecanico-api.desarrollo-software.xyz/api";

  bool get isLoggedIn => _user != null;
  bool get isStaff => _user?.isStaff ?? false;
  Usuario? get user => _user;

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint("REVISIÓN DE DATOS: $userData");

        _user = Usuario.fromJson(userData);

        final String? llave =
            userData['token'] ?? userData['key'] ?? userData['access'];

        if (llave != null) {
          ApiService().setToken(llave);
          debugPrint("✅ TOKEN ENCONTRADO Y GUARDADO");
        } else {
          debugPrint(
            "❌ ERROR: El servidor no envió 'token', 'key' ni 'access'",
          );
        }

        notifyListeners();
        return true; // CAMINO 1: Éxito (Ya lo tenías)
      } else {
        debugPrint("Error de credenciales: ${response.body}");
        return false; // CAMINO 2: Error de servidor/credenciales (Faltaba o estaba mal cerrado)
      }
    } catch (e) {
      debugPrint("Error de conexión en AuthProvider: $e");
      return false; // CAMINO 3: Error de red/excepción (Faltaba)
    }
    // No es estrictamente necesario si los anteriores cubren todo,
    // pero poner un 'return false;' aquí al final quita el error de Dart por completo.
  }

  void logout() {
    _user = null;
    // También limpiamos el token en el servicio al cerrar sesión
    ApiService().setToken("");
    notifyListeners();
  }
}
