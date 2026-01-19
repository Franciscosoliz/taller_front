import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

class IndustrialRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const IndustrialRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: onRefresh,
      builder: (context, child, controller) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            // CORRECCIÓN DEFINITIVA:
            // .isLoading detecta si está en fase de carga (refreshing)
            // .isArmed detecta si ya se estiró lo suficiente para activarse
            final bool isProcessing = controller.state.isLoading;
            final bool isIdle = controller.state.isIdle;

            return Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isIdle)
                  Positioned(
                    top: 35.0 * controller.value,
                    child: SizedBox(
                      height: 65,
                      child: Column(
                        children: [
                          // El engranaje gira proporcionalmente al desplazamiento
                          Transform.rotate(
                            angle: controller.value * 6.28,
                            child: const Icon(
                              Icons.settings,
                              size: 40,
                              color: Colors.amber,
                            ),
                          ),
                          // Mostramos el texto solo cuando está procesando el onRefresh
                          if (isProcessing)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                "SINCRONIZANDO...",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                // Desplazamos el contenido de la lista
                Transform.translate(
                  offset: Offset(0, 100.0 * controller.value),
                  child: child,
                ),
              ],
            );
          },
        );
      },
      child: child,
    );
  }
}
