import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taller_pro/providers/auth_provider.dart';
import '../widgets/metal_background.dart';
import 'table_manager.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MetalBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 120,
              pinned: true,
              actions: [
                // BOTÓN DE LOGOUT PARA FRANCISCO
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                  },
                )
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text(
                  "CENTRAL APP V8", 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 2,
                    fontSize: 16,
                    color: Colors.white
                  )
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 1.0, // Tarjetas más cuadradas para mejor visualización
                ),
                delegate: SliverChildListDelegate([
                  _buildAdminCard(context, "CLIENTES", Icons.people_alt, "clientes", Colors.blueAccent),
                  _buildAdminCard(context, "VEHÍCULOS", Icons.directions_car, "vehiculos", Colors.orangeAccent),
                  _buildAdminCard(context, "ÓRDENES", Icons.build_circle, "ordenes", Colors.greenAccent),
                  _buildAdminCard(context, "MECÁNICOS", Icons.engineering, "mecanicos", Colors.redAccent),
                  _buildAdminCard(context, "SERVICIOS", Icons.settings_suggest, "servicios", Colors.cyanAccent),
                  _buildAdminCard(context, "DETALLES", Icons.list_alt, "detalles", Colors.purpleAccent),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, String title, IconData icon, String endpoint, Color color) {
    return Card(
      elevation: 8,
      shadowColor: color.withValues(alpha:0.3),
      color: Colors.black.withValues(alpha:0.7), // Más oscuro para que resalte el texto
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withValues(alpha:0.4), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (context) => TableManagerScreen(
            endpoint: endpoint, 
            title: title, 
            accentColor: color
          )
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 35, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title, 
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold, 
                fontSize: 13,
                letterSpacing: 1
              )
            ),
          ],
        ),
      ),
    );
  }
}