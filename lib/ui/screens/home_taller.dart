import 'package:flutter/material.dart';
import 'package:taller_pro/api/mecanico_service.dart';
// import 'package:taller_pro/ui/screens/detalle_form.dart';
// import 'package:taller_pro/ui/screens/orden_form.dart';
import '../widgets/metal_background.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/industrial_refresh.dart';
// import 'appointment_form.dart';
import '../../services/pdf_service.dart';

class HomeTaller extends StatefulWidget {
  const HomeTaller({super.key});

  @override
  State<HomeTaller> createState() => _HomeTallerState();
}

class _HomeTallerState extends State<HomeTaller> {
  // Cambiamos el nombre para que sea más descriptivo: ya no son locales, son del servidor
  List<dynamic> ordenesDeTrabajo = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // MÉTODO CORREGIDO: Ahora pide los datos a Django
  Future<void> _cargarDatos() async {
    setState(() => isLoading = true);

    final service = MecanicoService();
    // Usamos el método que creamos anteriormente para obtener el 'results' del JSON
    final datos = await service.fetchOrdenes();

    setState(() {
      ordenesDeTrabajo = datos;
      isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    await _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: MetalBackground(
        child: IndustrialRefresh(
          onRefresh: _refreshData,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),

              // LISTA DE ÓRDENES
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                sliver: isLoading
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.amber),
                        ),
                      )
                    : ordenesDeTrabajo.isEmpty
                    ? _buildEmptyState()
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildServiceCard(ordenesDeTrabajo[index]),
                          childCount: ordenesDeTrabajo.length,
                        ),
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      // floatingActionButton: _buildFAB(),
    );
  }

  // Tarjeta adaptada al JSON de tu API
  // Tarjeta adaptada al JSON de tu API
  Widget _buildServiceCard(Map<String, dynamic> orden) {
    // 1. Extraemos los datos básicos de la orden actual
    final String placa = orden['vehiculo_placa']?.toString() ?? 'S/N';
    final String mecanico =
        orden['mecanico_nombre']?.toString() ?? 'No asignado';
    final String estado = orden['estado']?.toString() ?? 'Pendiente';
    final String obs =
        orden['observaciones']?.toString() ?? 'Sin observaciones';
    final String cliente = orden['cliente_nombre']?.toString() ?? 'Cliente V8';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _getStatusColor(estado).withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Icon(
          Icons.build_circle,
          color: _getStatusColor(estado),
          size: 40,
        ),
        title: Text(
          "PLACA: $placa",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mecánico: $mecanico",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 5),
            Text(
              obs,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(height: 10),
            _buildStatusBadge(estado),
          ],
        ),
        // BOTÓN PDF DINÁMICO
        trailing: IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.amber),
          onPressed: () {
            // 2. Construimos la lista de detalles dinámicamente.
            // Si tu JSON de 'orden' ya trae los detalles incluidos, úsalos.
            // Si no, enviamos la observación como el servicio principal.
            List<Map<String, dynamic>> detallesParaPdf = [];

            if (orden['detalles'] != null &&
                (orden['detalles'] as List).isNotEmpty) {
              // Si el backend devuelve detalles anidados:
              detallesParaPdf = (orden['detalles'] as List)
                  .map(
                    (d) => {
                      'servicio_nombre':
                          d['servicio_nombre']?.toString() ?? 'Servicio',
                      'cantidad': d['cantidad'] ?? 1,
                      'precio_unitario':
                          double.tryParse(d['precio_unitario'].toString()) ??
                          0.0,
                      'subtotal':
                          double.tryParse(d['subtotal'].toString()) ?? 0.0,
                    },
                  )
                  .toList();
            } else {
              // Si no hay detalles anidados, usamos la observación de la orden
              detallesParaPdf = [
                {
                  'servicio_nombre': obs,
                  'cantidad': 1,
                  'precio_unitario': 0.0,
                  'subtotal': 0.0,
                },
              ];
            }

            // 3. Generamos el PDF con la data de ESTA tarjeta
            PdfService.generateInvoice(
              cliente: cliente,
              placa: placa,
              mecanico: mecanico,
              detalles: detallesParaPdf,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Generando PDF para placa: $placa")),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGETS DE APOYO ---

  Color _getStatusColor(String estado) {
    if (estado.toLowerCase().contains('pendiente')) return Colors.amber;
    if (estado.toLowerCase().contains('listo') ||
        estado.toLowerCase().contains('finalizado'))
      return Colors.greenAccent;
    return Colors.cyanAccent;
  }

  Widget _buildStatusBadge(String estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(estado).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(estado).withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(estado),
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 120.0,
      pinned: true,
      flexibleSpace: const FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          "ORDENES V8",
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Text(
            "SISTEMA VACÍO - SIN ÓRDENES",
            style: TextStyle(color: Colors.white24, letterSpacing: 2),
          ),
        ),
      ),
    );
  }

  // Widget _buildFAB() {
  //   return FloatingActionButton.extended(
  //     backgroundColor: Colors.amber,
  //     elevation: 10,
  //     onPressed: () async {
  //       // Navega a la pantalla de creación de orden
  //       final result = await Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => const DetalleForm()),
  //       );

  //       // Si en OrdenForm usas Navigator.pop(context, true), esto refresca la lista
  //       if (result == true) {
  //         _cargarDatos();
  //       }
  //     },
  //     label: const Text(
  //       "NUEVA ORDEN",
  //       style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  //     ),
  //     icon: const Icon(Icons.add, color: Colors.black),
  //   );
  // }
}
