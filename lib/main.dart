import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importaciones de tus archivos (Asegúrate de que las rutas sean correctas)
import 'providers/auth_provider.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/home_taller.dart';
import 'ui/screens/admin_panel.dart'; // Importante para la parte de Francisco

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taller Pro Metal',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
        useMaterial3: true, // Look moderno tipo Android 13+
        scaffoldBackgroundColor: const Color(0xFF121212), // Fondo oscuro industrial
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // 1. Si NO está logueado, va siempre al Login
          if (!auth.isLoggedIn) {
            return LoginScreen();
          }

          // 2. Si SI está logueado, verificamos si es Francisco (Staff)
          // Si isStaff es true va al Panel Admin, si no, al Home normal
          return auth.isStaff ? const AdminPanel() : const HomeTaller();
        },
      ),
    );
  }
}