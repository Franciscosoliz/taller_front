import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// Esta función debe estar fuera de la clase para que funcione en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Mensaje recibido en segundo plano: ${message.messageId}");
}

class NotificationService {
  static Future<void> initialize() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. Solicitar permisos (Vital para iOS y Android 13+)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Permiso concedido por el usuario');
    }

    // 2. Obtener el Token del dispositivo (Token FCM)
    // Este token es el que guardarías en tu tabla de "usuarios" para enviar notificaciones personalizadas
    String? token = await messaging.getToken();
    debugPrint("Token FCM del dispositivo: $token");

    // 3. Manejar mensajes en SEGUNDO PLANO
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Manejar mensajes en PRIMER PLANO (App abierta)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Notificación en primer plano recibida:');
      debugPrint('Título: ${message.notification?.title}');
      debugPrint('Cuerpo: ${message.notification?.body}');
    });

    // 5. Manejar clicks en la notificación cuando la app está abierta de fondo
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('El usuario tocó la notificación!');
    });
  }
}