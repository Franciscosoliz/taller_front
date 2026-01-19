import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ServicioForm extends StatefulWidget {
  final Map<String, dynamic>? servicio;
  const ServicioForm({super.key, this.servicio});

  @override
  State<ServicioForm> createState() => _ServicioFormState();
}

class _ServicioFormState extends State<ServicioForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();

  final _nombreController = TextEditingController();
  final _descController = TextEditingController();
  final _precioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.servicio != null) {
      _nombreController.text = widget.servicio!['nombre'];
      _descController.text = widget.servicio!['descripcion'];
      _precioController.text = widget.servicio!['precio_referencial'].toString();
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "nombre": _nombreController.text,
      "descripcion": _descController.text,
      "precio_referencial": double.parse(_precioController.text),
    };

    bool exito = widget.servicio == null 
        ? await _api.createRecord('servicios', data)
        : await _api.updateRecord('servicios', widget.servicio!['id_servicio'], data);
    if (!mounted) return;
    if (exito) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(title: const Text("CATÁLOGO DE SERVICIOS"), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInput("NOMBRE DEL SERVICIO", _nombreController, Icons.build, Colors.cyanAccent),
              const SizedBox(height: 15),
              _buildInput("DESCRIPCIÓN / DETALLES", _descController, Icons.description, Colors.cyanAccent, maxLines: 3),
              const SizedBox(height: 15),
              _buildInput("PRECIO REFERENCIAL (\$)", _precioController, Icons.monetization_on, Colors.cyanAccent, isNumber: true),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
                onPressed: _guardar,
                child: const Text("REGISTRAR SERVICIO", style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon, Color color, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        labelStyle: TextStyle(color: color.withValues(alpha:0.7)),
        filled: true,
        fillColor: Colors.white.withValues(alpha:0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
    );
  }
}