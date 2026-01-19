import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DetalleForm extends StatefulWidget {
  final Map<String, dynamic>? detalle;
  const DetalleForm({super.key, this.detalle});

  @override
  State<DetalleForm> createState() => _DetalleFormState();
}

class _DetalleFormState extends State<DetalleForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();

  List<dynamic> _ordenes = [];
  List<dynamic> _servicios = [];

  int? _idOrden;
  int? _idServicio;
  final _cantidadController = TextEditingController(text: "1");
  final _precioController = TextEditingController();
  double _subtotal = 0.0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
    if (widget.detalle != null) {
      _idOrden = widget.detalle!['orden'];
      _idServicio = widget.detalle!['servicio'];
      _cantidadController.text = widget.detalle!['cantidad'].toString();
      _precioController.text = widget.detalle!['precio_unitario'].toString();
      _subtotal = double.parse(widget.detalle!['subtotal'].toString());
    }
  }

  Future<void> _cargarCatalogos() async {
    final o = await _api.getTable('ordenes');
    final s = await _api.getTable('servicios');
    setState(() {
      _ordenes = o;
      _servicios = s;
      _isLoading = false;
    });
  }

  void _calcularSubtotal() {
    final cant = double.tryParse(_cantidadController.text) ?? 0;
    final precio = double.tryParse(_precioController.text) ?? 0;
    setState(() {
      _subtotal = cant * precio;
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _idOrden == null || _idServicio == null) return;

    final data = {
      "orden": _idOrden,
      "servicio": _idServicio,
      "cantidad": int.parse(_cantidadController.text),
      "precio_unitario": double.parse(_precioController.text),
      "subtotal": _subtotal,
    };

    bool exito = widget.detalle == null 
        ? await _api.createRecord('detalles', data)
        : await _api.updateRecord('detalles', widget.detalle!['id_detalle'], data);
    if (!mounted) return;
    if (exito) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(title: const Text("DETALLE DE FACTURACIÓN"), backgroundColor: Colors.black),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildLabel("SELECCIONAR ORDEN #"),
                  _buildDropdown(_idOrden, _ordenes.map((o) => DropdownMenuItem(
                    value: o['id_orden'], child: Text("Orden #${o['id_orden']} - ${o['vehiculo_placa']}"))).toList(),
                    (val) => setState(() => _idOrden = val)),

                  const SizedBox(height: 15),

                  _buildLabel("SERVICIO"),
                  _buildDropdown(_idServicio, _servicios.map((s) => DropdownMenuItem(
                    value: s['id_servicio'], child: Text(s['nombre']))).toList(),
                    (val) {
                      setState(() {
                        _idServicio = val;
                        // Al seleccionar servicio, sugerir el precio referencial
                        final s = _servicios.firstWhere((x) => x['id_servicio'] == val);
                        _precioController.text = s['precio_referencial'].toString();
                        _calcularSubtotal();
                      });
                    }),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(child: _buildInput("CANTIDAD", _cantidadController, Icons.numbers, onChanged: (_) => _calcularSubtotal())),
                      const SizedBox(width: 10),
                      Expanded(child: _buildInput("PRECIO U.", _precioController, Icons.attach_money, onChanged: (_) => _calcularSubtotal())),
                    ],
                  ),

                  const SizedBox(height: 30),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.blueGrey.withValues(alpha:0.2), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("TOTAL LÍNEA:", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("\$${_subtotal.toStringAsFixed(2)}", style: const TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, padding: const EdgeInsets.all(15)),
                    onPressed: _guardar,
                    child: const Text("AGREGAR AL DETALLE", style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(color: Colors.cyanAccent, fontSize: 12)));

  Widget _buildDropdown(dynamic value, List<DropdownMenuItem<dynamic>> items, Function(dynamic) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(child: DropdownButton(value: value, items: items, onChanged: onChanged, isExpanded: true, dropdownColor: Colors.grey[900], style: const TextStyle(color: Colors.white))),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon, {Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: Colors.cyanAccent), labelStyle: const TextStyle(color: Colors.white60)),
    );
  }
}