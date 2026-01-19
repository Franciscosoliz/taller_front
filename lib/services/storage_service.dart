import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _userKey = 'sesion_usuario';

  // 1. GUARDAR LA SESIÓN (Cuando Francisco se loguea con éxito)
  static Future<void> guardarUsuario(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    // Guardamos el mapa del usuario (incluyendo el is_staff) como un String JSON
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  // 2. RECUPERAR LA SESIÓN (Al abrir la app)
  static Future<Map<String, dynamic>?> obtenerUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString(_userKey);
    
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null; // No hay sesión activa
  }

  // 3. CERRAR SESIÓN
  static Future<void> borrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // 4. MODO OFFLINE (OPCIONAL): Guardar caché de una tabla específica
  // Útil si Francisco se queda sin internet en el taller y quiere ver los clientes
  static Future<void> guardarCacheTabla(String tabla, List<dynamic> datos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cache_$tabla', jsonEncode(datos));
  }

  static Future<List<dynamic>> obtenerCacheTabla(String tabla) async {
    final prefs = await SharedPreferences.getInstance();
    String? datos = prefs.getString('cache_$tabla');
    return datos != null ? jsonDecode(datos) : [];
  }
}