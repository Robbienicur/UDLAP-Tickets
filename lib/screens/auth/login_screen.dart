import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'registro_screen.dart';
import '../home/home_screen.dart';
import 'recuperar_contraseña.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _mostrarContrasena = false;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  void _iniciarSesion() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
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
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                  ),
              const SizedBox(height: 28),
              Text(
                'UDLAP Tickets',
                textAlign: TextAlign.center,
                style: AppText.h1(color: AppColors.primary),
              )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                'Tu acceso digital al estacionamiento',
                textAlign: TextAlign.center,
                style: AppText.body(color: AppColors.textSecondary),
              ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 40),
              _AnimatedField(
                delay: 200.ms,
                child: TextField(
                  controller: _correoController,
                  decoration: InputDecoration(
                    labelText: 'Correo institucional',
                    hintText: 'estudiante@udlap.mx',
                    prefixIcon: PhosphorIcon(PhosphorIcons.envelope()),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 16),
              _AnimatedField(
                delay: 250.ms,
                child: TextField(
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
                  onPressed: _iniciarSesion,
                  child: const Text('Iniciar sesión'),
                ),
              ).animate(delay: 350.ms).fadeIn(duration: 400.ms).slideY(
                    begin: 0.15,
                    end: 0,
                  ),
              const SizedBox(height: 14),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _entrarComoInvitado,
                  child: const Text('Continuar como invitado'),
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
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
              ).animate(delay: 450.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedField extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedField({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }
}
