import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class VehiculoForm extends StatefulWidget {
  final Map<String, dynamic>? vehiculo; // Nulo para crear, con datos para editar
  const VehiculoForm({super.key, this.vehiculo});

  @override
  State<VehiculoForm> createState() => _VehiculoFormState();
}

class _VehiculoFormState extends State<VehiculoForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();

  // Controladores
  final _placaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anioController = TextEditingController();

  // Datos para el SELECT de Clientes
  List<dynamic> _clientes = [];
  int? _clienteSeleccionadoId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarClientes();
    if (widget.vehiculo != null) {
      _placaController.text = widget.vehiculo!['placa'];
      _marcaController.text = widget.vehiculo!['marca'];
      _modeloController.text = widget.vehiculo!['modelo'];
      _anioController.text = widget.vehiculo!['anio'].toString();
      _clienteSeleccionadoId = widget.vehiculo!['cliente']; // ID de la FK
    }
  }

  Future<void> _cargarClientes() async {
    final data = await _api.getTable('clientes');
    setState(() {
      _clientes = data;
      _isLoading = false;
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _clienteSeleccionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Faltan datos o seleccionar cliente")));
      return;
    }

    final data = {
      "placa": _placaController.text,
      "marca": _marcaController.text,
      "modelo": _modeloController.text,
      "anio": int.parse(_anioController.text),
      "cliente": _clienteSeleccionadoId, // Enviamos el ID al backend
    };

    bool exito;
    if (widget.vehiculo == null) {
      exito = await _api.createRecord('vehiculos', data);
    } else {
      exito = await _api.updateRecord('vehiculos', widget.vehiculo!['id_vehiculo'], data);
    }
    
    if (!mounted) return;
    if (exito) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: Text(widget.vehiculo == null ? "NUEVO VEHÍCULO" : "EDITAR VEHÍCULO"), backgroundColor: Colors.black),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildSelectCliente(),
                  const SizedBox(height: 20),
                  _buildInput("PLACA", _placaController, Icons.badge),
                  _buildInput("MARCA", _marcaController, Icons.directions_car),
                  _buildInput("MODELO", _modeloController, Icons.model_training),
                  _buildInput("AÑO", _anioController, Icons.calendar_today, isNumber: true),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                    onPressed: _guardar,
                    child: const Text("GUARDAR EN BASE DE DATOS"),
                  )
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSelectCliente() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonFormField<int>(
        initialValue: _clienteSeleccionadoId,
        dropdownColor: Colors.grey[900],
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(labelText: "CLIENTE PROPIETARIO", labelStyle: TextStyle(color: Colors.amber)),
        items: _clientes.map((c) => DropdownMenuItem<int>(
          value: c['id_cliente'],
          child: Text(c['nombre']),
        )).toList(),
        onChanged: (val) => setState(() => _clienteSeleccionadoId = val),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.amber),
      ),
      validator: (v) => v!.isEmpty ? "Obligatorio" : null,
    );
  }
}