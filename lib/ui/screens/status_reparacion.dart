import 'package:flutter/material.dart';
import 'package:taller_pro/models/reparacion.dart';
import 'package:taller_pro/services/api_service.dart';
import '../widgets/metal_background.dart';

class StatusReparacion extends StatefulWidget {
  const StatusReparacion({super.key});

  @override
  State<StatusReparacion> createState() => _StatusReparacionState();
}

class _StatusReparacionState extends State<StatusReparacion> {
  // Quitamos el late para evitar el error de inicialización
  Future<List<dynamic>>? _peticionesConcurrentes;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    setState(() {
      // Pedimos Detalles (Tareas) y Ordenes (Placa) al mismo tiempo
      _peticionesConcurrentes = Future.wait([
        ApiService().getTable('detalles'),
        ApiService().getTable('ordenes'),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "HOJA DE SERVICIO V8",
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: MetalBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: FutureBuilder<List<dynamic>>(
            future: _peticionesConcurrentes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(
                  child: Text(
                    "Error de conexión",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              // --- DEBUGGING: Imprime esto en tu consola de VS Code ---
              debugPrint(
                "DEBUG: Data de Ordenes (Index 1): ${snapshot.data![1]}",
              );

              // --- 1. LÓGICA PARA LA PLACA (DE LA TABLA ORDENES) ---
              String placaReal = "S/N";
              final resOrdenes =
                  snapshot.data![1]; // Tu lista: [{id_orden: 1, ...}]

              if (resOrdenes is List && resOrdenes.isNotEmpty) {
                // Como es una lista, accedemos al primer elemento [0] y luego al campo
                placaReal =
                    resOrdenes[0]['vehiculo_placa']?.toString() ?? "S/N";
              } else if (resOrdenes is Map &&
                  resOrdenes.containsKey('results')) {
                // Por si acaso Django cambie a paginado después
                List resultsList = resOrdenes['results'];
                if (resultsList.isNotEmpty) {
                  placaReal =
                      resultsList[0]['vehiculo_placa']?.toString() ?? "S/N";
                }
              }

              // --- 2. LÓGICA PARA LAS TAREAS (DE LA TABLA DETALLES) ---
              List<dynamic> listaTareasRaw = [];
              final resDetalles = snapshot.data![0];

              if (resDetalles is List) {
                listaTareasRaw = resDetalles;
              } else if (resDetalles is Map &&
                  resDetalles.containsKey('results')) {
                listaTareasRaw = resDetalles['results'];
              }

              final List<Reparacion> tareas = listaTareasRaw
                  .map((json) => Reparacion.fromJson(json))
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVehicleHeader("MI VEHÍCULO", placaReal),
                  const SizedBox(height: 25),
                  const Text(
                    "DIAGNÓSTICO Y AVANCES",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: tareas.isEmpty
                        ? const Center(
                            child: Text(
                              "No hay tareas",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: tareas.length,
                            itemBuilder: (context, index) =>
                                _buildTareaCard(tareas[index]),
                          ),
                  ),
                  _buildActionButtons(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleHeader(String nombre, String placa) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.directions_car_filled,
            color: Colors.amber,
            size: 40,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                "PLACA: $placa",
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTareaCard(Reparacion tarea) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tarea.pieza.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Icon(Icons.sync, color: Colors.cyanAccent, size: 20),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: 0.5, // Por defecto al 50% si no tienes el campo en la DB
            backgroundColor: Colors.white10,
            color: Colors.cyanAccent,
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          side: const BorderSide(color: Colors.cyanAccent, width: 0.5),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {},
        icon: const Icon(Icons.support_agent, color: Colors.cyanAccent),
        label: const Text(
          "CONSULTAR CON EL JEFE DE TALLER",
          style: TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
