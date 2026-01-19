import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Herramienta3D extends StatelessWidget {
  final String modelPath;

  const Herramienta3D({super.key, required this.modelPath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300, // Define el espacio vertical para el visor
      child: ModelViewer(
        backgroundColor: Colors.transparent,
        src: modelPath,
        alt: "Herramienta 3D del taller",
        ar: true,
        autoRotate: true,
        cameraControls: true,
        disableZoom: false,
      ),
    );
  }
}
