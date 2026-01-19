import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class OrdenForm extends StatefulWidget {
  final Map<String, dynamic>? orden; // Si viene datos, es edición
  const OrdenForm({super.key, this.orden});

  @override
  State<OrdenForm> createState() => _OrdenFormState();
}

class _OrdenFormState extends State<OrdenForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();

  // Datos para los SELECTS
  List<dynamic> _vehiculos = [];
  List<dynamic> _mecanicos = [];
  
  // Valores seleccionados (IDs de las FK)
  int? _idVehiculo;
  int? _idMecanico;
  String _estado = "pendiente"; // Valor por defecto
  
  final _obsController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosRelacionados();
    if (widget.orden != null) {
      _idVehiculo = widget.orden!['vehiculo'];
      _idMecanico = widget.orden!['mecanico'];
      _estado = widget.orden!['estado'];
      _obsController.text = widget.orden!['observaciones'] ?? "";
    }
  }

  Future<void> _cargarDatosRelacionados() async {
    final v = await _api.getTable('vehiculos');
    final m = await _api.getTable('mecanicos');
    setState(() {
      _vehiculos = v;
      _mecanicos = m;
      _isLoading = false;
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _idVehiculo == null || _idMecanico == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Por favor selecciona Vehículo y Mecánico")));
      return;
    }

    final data = {
      "vehiculo": _idVehiculo,
      "mecanico": _idMecanico,
      "estado": _estado,
      "observaciones": _obsController.text,
      "fecha_ingreso": widget.orden == null ? DateTime.now().toIso8601String() : widget.orden!['fecha_ingreso'],
      // La fecha de salida se podría asignar automáticamente al marcar como "finalizado"
    };

    bool exito;
    if (widget.orden == null) {
      exito = await _api.createRecord('ordenes', data);
    } else {
      exito = await _api.updateRecord('ordenes', widget.orden!['id_orden'], data);
    }
    if (!mounted) return;
    if (exito) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(widget.orden == null ? "NUEVA ORDEN" : "EDITAR ORDEN #${widget.orden!['id_orden']}"),
        backgroundColor: Colors.black,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
        : Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // SELECT DE VEHÍCULO
                  _buildLabel("VEHÍCULO (PLACA)"),
                  _buildDropdown(
                    value: _idVehiculo,
                    items: _vehiculos.map((v) => DropdownMenuItem<int>(
                      value: v['id_vehiculo'],
                      child: Text("${v['placa']} - ${v['marca']}"),
                    )).toList(),
                    onChanged: (val) => setState(() => _idVehiculo = val),
                  ),

                  const SizedBox(height: 20),

                  // SELECT DE MECÁNICO
                  _buildLabel("MECÁNICO ASIGNADO"),
                  _buildDropdown(
                    value: _idMecanico,
                    items: _mecanicos.map((m) => DropdownMenuItem<int>(
                      value: m['id_mecanico'],
                      child: Text(m['nombre']),
                    )).toList(),
                    onChanged: (val) => setState(() => _idMecanico = val),
                  ),

                  const SizedBox(height: 20),

                  // SELECT DE ESTADO
                  _buildLabel("ESTADO DE LA REPARACIÓN"),
                  _buildDropdown(
                    value: _estado,
                    items: const [
                      DropdownMenuItem(value: "pendiente", child: Text("PENDIENTE")),
                      DropdownMenuItem(value: "en proceso", child: Text("EN PROCESO")),
                      DropdownMenuItem(value: "finalizado", child: Text("FINALIZADO")),
                    ],
                    onChanged: (val) => setState(() => _estado = val.toString()),
                  ),

                  const SizedBox(height: 20),

                  // OBSERVACIONES
                  _buildLabel("OBSERVACIONES TÉCNICAS"),
                  TextFormField(
                    controller: _obsController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      fillColor: Colors.white10,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  const SizedBox(height: 40),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    onPressed: _guardar,
                    child: const Text("ACTUALIZAR ÓRDEN", style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDropdown({required dynamic value, required List<DropdownMenuItem<dynamic>> items, required Function(dynamic) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          value: value,
          dropdownColor: Colors.grey[900],
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}