import 'package:flutter/material.dart';

class MetalBackground extends StatelessWidget {
  final Widget child;

  const MetalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        // Degradado que imita el acero cepillado
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.3, 0.5, 0.8, 1.0],
          colors: [
            Color(0xFF424242), // Gris carbón
            Color(0xFF757575), // Acero medio
            Color(0xFFBDBDBD), // Plata claro
            Color(0xFF616161), // Sombra metálica
            Color(0xFF212121), // Negro industrial
          ],
        ),
      ),
      child: Stack(
        children: [
          // Añadimos un patrón de "textura" sutil
          Opacity(
            opacity: 0.05,
            child: GridPaper(
              color: Colors.white,
              divisions: 1,
              subdivisions: 1,
              interval: 100,
              child: Container(),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}