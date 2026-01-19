import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taller_pro/ui/screens/public_screen.dart';
import '../../providers/auth_provider.dart';
import '../widgets/metal_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Lógica de autenticación real conectada a tu Provider
  void _handleLogin() async {
    // Validamos que no haya campos vacíos
    if (_userController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Ingrese credenciales de técnico")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Obtenemos el provider sin escuchar cambios (listen: false)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // El .trim() es vital para evitar errores por espacios accidentales
    bool success = await authProvider.login(
      _userController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        // Si el login es correcto, el AuthProvider notificará a main.dart
        // y la app cambiará automáticamente a la pantalla de inicio.
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Acceso concedido")));
      } else {
        // Si falla, mostramos el error de credenciales
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("❌ Acceso denegado: Credenciales inválidas"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MetalBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                // Icono con resplandor ámbar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.engineering,
                    size: 90,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "TALLER MECANICO V8",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const Text(
                  "UNIDAD DE CONTROL DE ACCESO",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 50),

                _buildInputField(
                  label: "CÓDIGO DE USUARIO",
                  controller: _userController,
                  icon: Icons.person_search,
                  hint: "Usuario técnico",
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: "LLAVE DE SEGURIDAD",
                  controller: _passwordController,
                  icon: Icons.vpn_key,
                  hint: "••••••••",
                  obscure: true,
                ),
                const SizedBox(height: 40),

                _isLoading
                    ? const CircularProgressIndicator(color: Colors.amber)
                    : _buildLoginButton(),

                const SizedBox(height: 30),
                // Opción para clientes que no tienen cuenta
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PublicScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "MODO DE INVITADO / CONSULTA",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.amber, size: 20),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Colors.amber, Color(0xFFFFB300)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          "INICIAR SISTEMA",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
