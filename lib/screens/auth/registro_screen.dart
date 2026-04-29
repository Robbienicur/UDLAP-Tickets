import 'package:flutter/material.dart';
import '../home/home_screen.dart';

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
    if (pass.isEmpty || pass.length < 6) return Colors.redAccent;
    if (pass.length < 10) return Colors.orangeAccent;
    return Colors.green;
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
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? helperText,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      helperText: helperText,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.92),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.indigo, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: SingleChildScrollView(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
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
                  children: [
                    const SizedBox(height: 20),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.86),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withValues(alpha: 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_add_alt_1_rounded,
                                  color: Colors.indigo),
                              SizedBox(width: 8),
                              Text(
                                'Crea tu cuenta',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Completa los datos para continuar.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _nombreController,
                      decoration: _inputDecoration(
                        label: 'Nombre',
                        icon: Icons.person_outline,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _apellidoController,
                      decoration: _inputDecoration(
                        label: 'Apellido',
                        icon: Icons.badge_outlined,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tu apellido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _correoController,
                      decoration: _inputDecoration(
                        label: 'Correo',
                        icon: Icons.email_outlined,
                        helperText: 'Usa tu correo institucional',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final correo = value?.trim() ?? '';
                        if (correo.isEmpty) {
                          return 'Ingresa tu correo';
                        }
                        if (!correo.contains('@') || !correo.contains('.')) {
                          return 'Correo no valido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _contrasenaController,
                      decoration: _inputDecoration(
                        label: 'Contrasena',
                        icon: Icons.lock_outline,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              _mostrarContrasena = !_mostrarContrasena;
                            });
                          },
                          icon: Icon(
                            _mostrarContrasena
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      obscureText: !_mostrarContrasena,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Minimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: _contrasenaController.text.isEmpty ? 0 : 22,
                      alignment: Alignment.centerLeft,
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
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _confirmarController,
                      decoration: _inputDecoration(
                        label: 'Confirmar Contrasena',
                        icon: Icons.lock_reset_outlined,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              _mostrarConfirmacion = !_mostrarConfirmacion;
                            });
                          },
                          icon: Icon(
                            _mostrarConfirmacion
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      obscureText: !_mostrarConfirmacion,
                      validator: (value) {
                        if (value != _contrasenaController.text) {
                          return 'Las contrasenas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Atras'),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 180),
                            scale: _progresoRegistro == 1 ? 1.0 : 0.98,
                            child: ElevatedButton(
                              onPressed: _registrarse,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: const Text('Sig.'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
