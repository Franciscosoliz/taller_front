import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MecanicoForm extends StatefulWidget {
  final Map<String, dynamic>? mecanico;
  const MecanicoForm({super.key, this.mecanico});

  @override
  State<MecanicoForm> createState() => _MecanicoFormState();
}

class _MecanicoFormState extends State<MecanicoForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();

  final _nombreController = TextEditingController();
  final _especialidadController = TextEditingController();
  final _telefonoController = TextEditingController();
  String _estado = "activo";

  @override
  void initState() {
    super.initState();
    if (widget.mecanico != null) {
      _nombreController.text = widget.mecanico!['nombre'];
      _especialidadController.text = widget.mecanico!['especialidad'];
      _telefonoController.text = widget.mecanico!['telefono'];
      _estado = widget.mecanico!['estado'];
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "nombre": _nombreController.text,
      "especialidad": _especialidadController.text,
      "telefono": _telefonoController.text,
      "estado": _estado,
    };

    bool exito = widget.mecanico == null 
        ? await _api.createRecord('mecanicos', data)
        : await _api.updateRecord('mecanicos', widget.mecanico!['id_mecanico'], data);
    if (!mounted) return;
    if (exito) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(title: const Text("GESTIÓN DE MECÁNICOS"), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInput("NOMBRE COMPLETO", _nombreController, Icons.person, Colors.redAccent),
              const SizedBox(height: 15),
              _buildInput("ESPECIALIDAD", _especialidadController, Icons.star, Colors.redAccent),
              const SizedBox(height: 15),
              _buildInput("TELÉFONO", _telefonoController, Icons.phone, Colors.redAccent, isPhone: true),
              const SizedBox(height: 15),
              const Text("ESTADO LABORAL", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _estado,
                    isExpanded: true,
                    dropdownColor: Colors.grey[900],
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: "activo", child: Text("ACTIVO")),
                      DropdownMenuItem(value: "inactivo", child: Text("INACTIVO")),
                    ],
                    onChanged: (val) => setState(() => _estado = val!),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                onPressed: _guardar,
                child: const Text("GUARDAR MECÁNICO"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon, Color color, {bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        labelStyle: const TextStyle(color: Colors.white60),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: color.withValues(alpha:0.5))),
      ),
      validator: (v) => v!.isEmpty ? "Requerido" : null,
    );
  }
}