import 'package:flutter/material.dart';
import 'package:taller_pro/ui/screens/cliente_form.dart';
import 'package:taller_pro/ui/screens/mecanico_form.dart';
import 'package:taller_pro/ui/screens/orden_form.dart';
import 'package:taller_pro/ui/screens/vehiculo_form.dart';
import '../../services/api_service.dart';
// Asegúrate de importar todos tus formularios aquí:
// import 'forms/cliente_form.dart';
// etc...

class TableManagerScreen extends StatefulWidget {
  final String endpoint;
  final String title;
  final Color accentColor;

  const TableManagerScreen({
    super.key,
    required this.endpoint,
    required this.title,
    required this.accentColor,
  });

  @override
  State<TableManagerScreen> createState() => _TableManagerScreenState();
}

class _TableManagerScreenState extends State<TableManagerScreen> {
  final ApiService api = ApiService();
  List<dynamic> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    final data = await api.getTable(widget.endpoint);
    if (!mounted) return;
    setState(() {
      items = data;
      isLoading = false;
    });
  }

  // CORRECCIÓN: Método de navegación unificado para Agregar y Editar
  void _navigateToForm({Map<String, dynamic>? item}) async {
    bool? refresh;

    // Dependiendo del endpoint, abrimos el formulario correspondiente
    switch (widget.endpoint) {
      case 'clientes':
        refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => ClienteForm(cliente: item)));
        break;
      case 'vehiculos':
        refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => VehiculoForm(vehiculo: item)));
        break;
      case 'mecanicos':
        refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => MecanicoForm(mecanico: item)));
        break;
      case 'ordenes':
        refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => OrdenForm(orden: item)));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Formulario para ${widget.endpoint} no implementado"),
          ),
        );
    }

    if (refresh == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildListItem(item);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: widget.accentColor,
        onPressed: () => _navigateToForm(), // Sin 'item' para crear nuevo
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: widget.accentColor, width: 5)),
      ),
      child: ListTile(
        title: Text(
          _getMainTitle(item),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          _getSubtitle(item),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () =>
                  _navigateToForm(item: item), // Pasamos el item para editar
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _confirmDelete(item),
            ),
          ],
        ),
      ),
    );
  }

  String _getMainTitle(Map<String, dynamic> item) {
    return item['nombre'] ??
        item['placa'] ??
        item['servicio_nombre'] ??
        "ID: ${item.values.first}";
  }

  String _getSubtitle(Map<String, dynamic> item) {
    return item['telefono'] ?? item['marca'] ?? item['estado'] ?? "";
  }

  void _confirmDelete(Map<String, dynamic> item) {
    int id = item.values.first; // Asume que el ID es el primer campo del JSON
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "¿Eliminar registro?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Esta acción no se puede deshacer.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await api.deleteRecord(widget.endpoint, id);
              if (mounted) {
                if (!context.mounted) return;
                Navigator.pop(context);
                _refresh();
              }
            },
            child: const Text("ELIMINAR"),
          ),
        ],
      ),
    );
  }
}
