import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/metal_background.dart';

class PublicScreen extends StatefulWidget {
  const PublicScreen({super.key});

  @override
  State<PublicScreen> createState() => _PublicScreenState();
}

class _PublicScreenState extends State<PublicScreen> {
  final _plateController = TextEditingController();
  bool _isSearching = false;

  final String baseUrl = "https://soliz-francisco-taller-mecanico-api.desarrollo-software.xyz/api";

  void _handleSearch() async {
    String plate = _plateController.text.trim().toUpperCase();

    if (plate.isEmpty) {
      _showSnackBar("⚠️ Ingrese la placa del vehículo");
      return;
    }

    setState(() => _isSearching = true);

    try {
      // Filtrado directo por placa en la URL
      final response = await http.get(
        Uri.parse("$baseUrl/ordenes/?vehiculo_placa=$plate"),
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(utf8.decode(response.bodyBytes));
        List<dynamic> data = [];

        // Manejo de respuesta flexible (Lista o Mapa con results)
        if (decodedData is List) {
          data = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('results')) {
          data = decodedData['results'];
        }

        if (data.isNotEmpty) {
          // Buscamos la coincidencia exacta por seguridad
          final orden = data.firstWhere(
            (o) => o['vehiculo_placa'].toString().toUpperCase() == plate,
            orElse: () => data[0],
          );
          _showResultDialog(orden);
        } else {
          _showSnackBar("❌ No hay órdenes activas para la placa $plate");
        }
      } else {
        _showSnackBar("❌ Error de servidor: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
      _showSnackBar("⚠️ Error de conexión: Compruebe su internet");
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _showResultDialog(Map<String, dynamic> orden) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.amber, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        title: const Text(
          "ESTADO DEL TRABAJO",
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Placa:", "${orden['vehiculo_placa'] ?? _plateController.text.toUpperCase()}"),
            _detailRow("Estado:", "${orden['estado']?.toString().toUpperCase() ?? 'PENDIENTE'}"),
            _detailRow("Técnico:", "${orden['mecanico_nombre'] ?? 'Asignado'}"),
            const Divider(color: Colors.white24),
            Text(
              "Observaciones:",
              style: TextStyle(color: Colors.amber[200], fontSize: 12),
            ),
            const SizedBox(height: 5),
            Text(
              "${orden['observaciones'] ?? 'Sin detalles adicionales'}",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CERRAR", style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  // --- El resto del código build, _detailRow, _buildPlateInput y _buildSearchButton se mantiene igual ---

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label ",
              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: MetalBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
                  ),
                  child: const Icon(Icons.manage_search, size: 80, color: Colors.amber),
                ),
                const SizedBox(height: 30),
                const Text(
                  "CONSULTA DE ESTADO",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                ),
                const SizedBox(height: 50),
                _buildPlateInput(),
                const SizedBox(height: 40),
                _isSearching ? const CircularProgressIndicator(color: Colors.amber) : _buildSearchButton(),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlateInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("PLACA DEL VEHÍCULO", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: TextField(
            controller: _plateController,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 5),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: "ABC-1234", hintStyle: TextStyle(color: Colors.white10), border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: _handleSearch,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.amber, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: const Text("CONSULTAR AHORA", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}