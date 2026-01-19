import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ClienteForm extends StatefulWidget {
  final Map<String, dynamic>? cliente;
  const ClienteForm({super.key, this.cliente});

  @override
  State<ClienteForm> createState() => _ClienteFormState();
}

class _ClienteFormState extends State<ClienteForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();

  // Controladores de texto
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _direccionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Si estamos editando, cargamos los datos existentes
    if (widget.cliente != null) {
      _nombreController.text = widget.cliente!['nombre'] ?? '';
      _telefonoController.text = widget.cliente!['telefono'] ?? '';
      _correoController.text = widget.cliente!['correo'] ?? '';
      _direccionController.text = widget.cliente!['direccion'] ?? '';
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "nombre": _nombreController.text,
      "telefono": _telefonoController.text,
      "correo": _correoController.text,
      "direccion": _direccionController.text,
    };

    bool exito;
    if (widget.cliente == null) {
      exito = await _api.createRecord('clientes', data);
    } else {
      // Usamos el ID de la tabla para el PUT
      exito = await _api.updateRecord('clientes', widget.cliente!['id_cliente'], data);
    }

    if (exito) {
      if (mounted) Navigator.pop(context, true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al conectar con la API")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.cliente == null ? "REGISTRAR CLIENTE" : "EDITAR CLIENTE"),
        backgroundColor: Colors.black,
        elevation: 10,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Icon(Icons.person_add, size: 80, color: Colors.amber),
              const SizedBox(height: 20),
              
              _buildField("NOMBRE COMPLETO", _nombreController, Icons.person),
              const SizedBox(height: 15),
              
              _buildField("TELÉFONO", _telefonoController, Icons.phone, isPhone: true),
              const SizedBox(height: 15),
              
              _buildField("CORREO ELECTRÓNICO", _correoController, Icons.email, isEmail: true),
              const SizedBox(height: 15),
              
              _buildField("DIRECCIÓN DE DOMICILIO", _direccionController, Icons.map, maxLines: 2),
              
              const SizedBox(height: 40),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _guardar,
                child: const Text("GUARDAR CLIENTE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool isPhone = false, bool isEmail = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isPhone ? TextInputType.phone : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber, fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.amber),
        filled: true,
        fillColor: Colors.white.withValues(alpha:0.05),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber.withValues(alpha:0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (v) => v!.isEmpty ? "Este campo es requerido" : null,
    );
  }
}