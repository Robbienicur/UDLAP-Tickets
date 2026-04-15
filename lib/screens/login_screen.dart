import 'package:flutter/material.dart';
import 'registro_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  bool _ocultarContrasena = true;
  bool _cargando = false;
  String _mensajeError = '';

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _mensajeError = '';
    });

    await Future.delayed(const Duration(seconds: 1));

    final correo = _correoController.text.trim();
    final contrasena = _contrasenaController.text.trim();

    const correoValido = 'estudiante@udlap.mx';
    const contrasenaValida = '123456';

    if (!mounted) return;

    if (correo == correoValido && contrasena == contrasenaValida) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      setState(() {
        _mensajeError = 'Correo o contraseña incorrectos';
        _cargando = false;
      });
    }
  }

  void _irARegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistroScreen()),
    );
  }

  void _entrarComoInvitado() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _recuperarContrasena() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de recuperación aún no implementada'),
      ),
    );
  }

  String? _validarCorreo(String? value) {
    final texto = value?.trim() ?? '';

    if (texto.isEmpty) {
      return 'Ingresa tu correo institucional';
    }

    if (!texto.contains('@') || !texto.contains('.')) {
      return 'Ingresa un correo válido';
    }

    return null;
  }

  String? _validarContrasena(String? value) {
    final texto = value?.trim() ?? '';

    if (texto.isEmpty) {
      return 'Ingresa tu contraseña';
    }

    if (texto.length < 6) {
      return 'Debe tener al menos 6 caracteres';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.confirmation_num,
                          size: 72,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Inicio de Sesión',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Inicia sesión para acceder a la aplicación',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _correoController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo Institucional',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: _validarCorreo,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _contrasenaController,
                          obscureText: _ocultarContrasena,
                          decoration: InputDecoration(
                            labelText: 'Contraseña Institucional',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _ocultarContrasena = !_ocultarContrasena;
                                });
                              },
                              icon: Icon(
                                _ocultarContrasena
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          validator: _validarContrasena,
                        ),
                        const SizedBox(height: 12),
                        if (_mensajeError.isNotEmpty)
                          Text(
                            _mensajeError,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _cargando ? null : _iniciarSesion,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: _cargando
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Iniciar Sesión'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _irARegistro,
                          child: const Text('Registrarse'),
                        ),
                        TextButton(
                          onPressed: _recuperarContrasena,
                          child: const Text('Olvidé mi contraseña'),
                        ),
                        TextButton(
                          onPressed: _entrarComoInvitado,
                          child: const Text('Invitado'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}