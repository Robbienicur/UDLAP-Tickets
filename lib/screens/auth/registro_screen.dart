import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../home/home_screen.dart';
import '../../theme/app_theme.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarController = TextEditingController();

  bool _mostrarContrasena = false;
  bool _mostrarConfirmacion = false;

  double get _progresoRegistro {
    int completos = 0;
    if (_nombreController.text.trim().isNotEmpty) completos++;
    if (_apellidoController.text.trim().isNotEmpty) completos++;
    if (_correoController.text.trim().isNotEmpty) completos++;
    if (_contrasenaController.text.isNotEmpty) completos++;
    if (_confirmarController.text.isNotEmpty) completos++;
    return completos / 5;
  }

  String _fortalezaContrasena() {
    final pass = _contrasenaController.text;
    if (pass.isEmpty) return '';
    if (pass.length < 6) return 'Fortaleza: Baja';
    if (pass.length < 10) return 'Fortaleza: Media';
    return 'Fortaleza: Alta';
  }

  Color _fortalezaColor() {
    final pass = _contrasenaController.text;
    if (pass.isEmpty || pass.length < 6) return AppColors.error;
    if (pass.length < 10) return AppColors.accentDark;
    return AppColors.success;
  }

  void _actualizarUI() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _nombreController.addListener(_actualizarUI);
    _apellidoController.addListener(_actualizarUI);
    _correoController.addListener(_actualizarUI);
    _contrasenaController.addListener(_actualizarUI);
    _confirmarController.addListener(_actualizarUI);
  }

  @override
  void dispose() {
    _nombreController.removeListener(_actualizarUI);
    _apellidoController.removeListener(_actualizarUI);
    _correoController.removeListener(_actualizarUI);
    _contrasenaController.removeListener(_actualizarUI);
    _confirmarController.removeListener(_actualizarUI);
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  void _registrarse() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa los campos para continuar.'),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 12),
                  child: child,
                ),
              );
            },
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.userPlus(PhosphorIconsStyle.fill),
                          color: AppColors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Crea tu cuenta',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Completa los datos para continuar',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _progresoRegistro,
                      minHeight: 6,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: PhosphorIcon(PhosphorIcons.user()),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tu nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _apellidoController,
                    decoration: InputDecoration(
                      labelText: 'Apellido',
                      prefixIcon: PhosphorIcon(PhosphorIcons.identificationBadge()),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tu apellido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _correoController,
                    decoration: InputDecoration(
                      labelText: 'Correo institucional',
                      prefixIcon: PhosphorIcon(PhosphorIcons.envelope()),
                      helperText: 'Usa tu correo @udlap.mx',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final correo = value?.trim() ?? '';
                      if (correo.isEmpty) return 'Ingresa tu correo';
                      if (!correo.contains('@') || !correo.contains('.')) {
                        return 'Correo no válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _contrasenaController,
                    obscureText: !_mostrarContrasena,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: PhosphorIcon(PhosphorIcons.lock()),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _mostrarContrasena = !_mostrarContrasena;
                          });
                        },
                        icon: PhosphorIcon(
                          _mostrarContrasena
                              ? PhosphorIcons.eyeSlash()
                              : PhosphorIcons.eye(),
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: _contrasenaController.text.isEmpty ? 0 : 24,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: _contrasenaController.text.isEmpty
                        ? const SizedBox.shrink()
                        : Text(
                            _fortalezaContrasena(),
                            style: TextStyle(
                              color: _fortalezaColor(),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmarController,
                    obscureText: !_mostrarConfirmacion,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: PhosphorIcon(PhosphorIcons.shieldCheck()),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _mostrarConfirmacion = !_mostrarConfirmacion;
                          });
                        },
                        icon: PhosphorIcon(
                          _mostrarConfirmacion
                              ? PhosphorIcons.eyeSlash()
                              : PhosphorIcons.eye(),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value != _contrasenaController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              Navigator.pop(context);
                            },
                            child: const Text('Atrás'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              _registrarse();
                            },
                            child: const Text('Registrarme'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
