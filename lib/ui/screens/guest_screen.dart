import 'package:flutter/material.dart';
import '../widgets/metal_background.dart';
import 'appointment_form.dart'; // El formulario que enviaste
import 'home_taller.dart';      // Para ver el historial

class GuestScreen extends StatelessWidget {
  const GuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MetalBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.minor_crash, size: 100, color: Colors.amber),
                const SizedBox(height: 20),
                const Text(
                  "BIENVENIDO A TALLER MECANICO V8",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2
                  ),
                ),
                const Text(
                  "Servicio Técnico Especializado",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 60),
                
                // BOTÓN 1: AGENDAR
                _buildMenuButton(
                  context, 
                  "AGENDAR CITA", 
                  Icons.calendar_today, 
                  Colors.amber,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AppointmentForm()))
                ),
                
                const SizedBox(height: 20),
                
                // BOTÓN 2: MIS CITAS
                _buildMenuButton(
                  context, 
                  "VER MIS CITAS", 
                  Icons.history, 
                  Colors.white24,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeTaller()))
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: color == Colors.amber ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}