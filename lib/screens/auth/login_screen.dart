import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'registro_screen.dart';
import '../home/home_screen.dart';
import 'recuperar_contraseña.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _mostrarContrasena = false;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
    });

    final success = await _apiService.login(
      _correoController.text,
      _contrasenaController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de inicio de sesión. Verifique sus credenciales.')),
      );
    }
  }

  void _irARegistro() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistroScreen()),
    );
  }

  void _entrarComoInvitado() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(esInvitado: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/images/udlap-tickets-logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'UDLAP Tickets',
                textAlign: TextAlign.center,
                style: AppText.h1(color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu acceso digital al estacionamiento',
                textAlign: TextAlign.center,
                style: AppText.body(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _correoController,
                decoration: InputDecoration(
                  labelText: 'Correo institucional',
                  hintText: 'estudiante@udlap.mx',
                  prefixIcon: PhosphorIcon(PhosphorIcons.envelope()),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contrasenaController,
                obscureText: !_mostrarContrasena,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: PhosphorIcon(PhosphorIcons.lock()),
                  suffixIcon: IconButton(
                    icon: PhosphorIcon(
                      _mostrarContrasena
                          ? PhosphorIcons.eyeSlash()
                          : PhosphorIcons.eye(),
                    ),
                    onPressed: () {
                      setState(
                        () => _mostrarContrasena = !_mostrarContrasena,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecuperarContrasenaScreen(),
                      ),
                    );
                  },
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _iniciarSesion,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Iniciar sesión'),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _entrarComoInvitado,
                  child: const Text('Continuar como invitado'),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No tienes cuenta?',
                    style: AppText.body(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: _irARegistro,
                    child: const Text('Regístrate'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
