import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class HerramientaCargando extends StatelessWidget {
  const HerramientaCargando({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Roulette( // Animación de rotación
        infinite: true,
        duration: Duration(seconds: 2),
        child: Icon(Icons.settings, size: 100, color: Colors.amber),
      ),
    );
  }
}