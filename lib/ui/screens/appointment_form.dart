import 'package:flutter/material.dart';
import '../widgets/metal_background.dart';
import '../../api/mecanico_service.dart';

class AppointmentForm extends StatefulWidget {
  const AppointmentForm({super.key});

  @override
  State<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  final MecanicoService _apiService = MecanicoService();

  final _clienteController = TextEditingController();
  final _placaController = TextEditingController();

  String _tipoVehiculo = 'Sedán';
  DateTime _fechaCita = DateTime.now();
  bool _isSending = false; // Para evitar múltiples clics

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: MetalBackground(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: BackButton(color: Colors.amber),
              title: Text(
                "NUEVA ORDEN TÉCNICA",
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white),
              ),
              floating: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("DATOS DEL PROPIETARIO"),
                      _buildInputField(
                        label: "NOMBRE COMPLETO",
                        controller: _clienteController,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 25),

                      _buildSectionTitle("ESPECIFICACIONES DEL VEHÍCULO"),
                      _buildInputField(
                        label: "PLACA / MATRÍCULA",
                        controller: _placaController,
                        icon: Icons.confirmation_number_outlined,
                      ),
                      const SizedBox(height: 20),

                      _buildDropdownField(
                        label: "TIPO DE VEHÍCULO",
                        value: _tipoVehiculo,
                        items: ['Sedán', 'SUV', 'Camioneta', 'Deportivo', 'Moto'],
                        onChanged: (val) => setState(() => _tipoVehiculo = val!),
                      ),
                      const SizedBox(height: 25),

                      _buildSectionTitle("PROGRAMACIÓN"),
                      _buildDatePicker(),

                      const SizedBox(height: 50),

                      _isSending 
                        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                        : _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LÓGICA DE GUARDADO MEJORADA ---
  Future<void> _procesarRegistro() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSending = true);

      Map<String, dynamic> nuevaCita = {
        "cliente": _clienteController.text,
        "auto": _placaController.text,
        "tipo": _tipoVehiculo,
        "estado": "Recién Ingresado",
        "fecha": _fechaCita.toIso8601String(),
      };

      // 1. INTENTAR GUARDAR EN LA NUBE (API)
      // Nota: Asegúrate de tener el método crearCita en tu MecanicoService
      bool exitoApi = await _apiService.crearCita(nuevaCita);

      // 2. GUARDAR EN EL TELÉFONO (Para que el cliente vea su historial offline)
      if (mounted) {
        String mensaje = exitoApi 
            ? "✅ ORDEN REGISTRADA EN SISTEMA Y DISCO" 
            : "⚠️ GUARDADO LOCAL (SIN CONEXIÓN)";
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
        Navigator.pop(context, true);
      }
    }
  }

  // --- COMPONENTES UI (Manteniendo tu estilo original) ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
          prefixIcon: Icon(icon, color: Colors.amber),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) => value!.isEmpty ? "Campo requerido" : null,
      ),
    );
  }

  Widget _buildDropdownField({required String label, required String value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white54), border: InputBorder.none),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _fechaCita,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
        );
        if (date != null) setState(() => _fechaCita = date);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withValues(alpha:0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("FECHA DE INGRESO", style: TextStyle(color: Colors.white70)),
            Text("${_fechaCita.day}/${_fechaCita.month}/${_fechaCita.year}",
              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 10,
        ),
        onPressed: _procesarRegistro,
        child: const Text("REGISTRAR EN EL SISTEMA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _placaController.dispose();
    super.dispose();
  }
}