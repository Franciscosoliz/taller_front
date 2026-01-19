import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../screens/status_reparacion.dart';
import '../screens/stats_screen.dart'; // Importamos las estadísticas
import '../../services/pdf_service.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el estado del usuario para personalizar el menú
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isAdmin = authProvider.isStaff;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
            border: const Border(
              right: BorderSide(color: Colors.amber, width: 0.5),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(isAdmin),
              const SizedBox(height: 10),

              // SECCIÓN PRINCIPAL
              _drawerItem(
                icon: Icons.speed,
                title: "PANEL DE CONTROL",
                onTap: () => Navigator.pop(context),
              ),

              if (isAdmin) ...[
                _drawerItem(
                  icon: Icons.analytics_outlined,
                  title: "TELEMETRÍA (STATS)",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StatsScreen(),
                      ),
                    );
                  },
                ),
              ],

              _drawerItem(
                icon: Icons.build_circle_outlined,
                title: "HOJA DE SERVICIO",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatusReparacion(),
                    ),
                  );
                },
              ),

              const Divider(color: Colors.white10, indent: 20, endIndent: 20),

              // SECCIÓN DE SERVICIOS
              _drawerItem(
                icon: Icons.picture_as_pdf,
                title: "REPORTE TÉCNICO PDF",
                color: Colors.redAccent,
                onTap: () {
                  PdfService.generateInvoice(
                    cliente: "Consulta General",
                    placa: "TALLER-V8",
                    mecanico: "Francisco Soliz",
                    detalles: [],
                  );
                },
              ),

              _drawerItem(
                icon: Icons.location_on_outlined,
                title: "UBICACIÓN GPS",
                color: Colors.cyanAccent,
                onTap: () => _launchMaps(),
              ),

              const Spacer(),

              // FOOTER Y LOGOUT
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isAdmin) {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        color: Colors.amber.withValues(alpha: 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.settings_input_component,
              size: 50,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            const Text(
              "TALLER MECANICO V8 PRO",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: isAdmin ? Colors.amber : Colors.blueGrey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAdmin ? "MODO STAFF" : "MODO CLIENTE",
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.amber,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Column(
      children: [
        const Divider(color: Colors.white10, height: 1),
        ListTile(
          onTap: () =>
              Provider.of<AuthProvider>(context, listen: false).logout(),
          leading: const Icon(
            Icons.power_settings_new,
            color: Colors.redAccent,
          ),
          title: const Text(
            "DESCONECTAR SISTEMA",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          tileColor: Colors.red.withValues(alpha: 0.05),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Future<void> _launchMaps() async {
    const String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=-0.1807,-78.4678";
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(
        Uri.parse(googleMapsUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
