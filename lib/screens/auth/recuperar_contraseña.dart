import 'package:flutter/material.dart';

class RecuperarContrasenaScreen extends StatefulWidget {
  const RecuperarContrasenaScreen({super.key});

  @override
  State<RecuperarContrasenaScreen> createState() =>
      _RecuperarContrasenaScreenState();
}

class _RecuperarContrasenaScreenState
    extends State<RecuperarContrasenaScreen> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();

  bool _codigoEnviado = false;
  String _mensajeExito = '';
  String _mensajeError = '';

  static const String _correoRegistrado = 'estudiante@udlap.mx';
  static const String _codigoCorrecto = '123';

  @override
  void dispose() {
    _correoController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _mostrarCarga(String titulo) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Cargando',
      pageBuilder: (_, __, ___) {
        return Material(
          color: const Color(0xFFF3F4F8),
          child: _PantallaCarga(titulo: titulo),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _limpiarMensajes() {
    _mensajeExito = '';
    _mensajeError = '';
  }

  Future<void> _enviarCodigo() async {
    FocusScope.of(context).unfocus();

    final correo = _correoController.text.trim();

    setState(() {
      _limpiarMensajes();
    });

    if (correo.isEmpty) {
      setState(() {
        _mensajeError =
            'Error: Antes de enviar el código debe proporcionar su correo institucional.';
      });
      return;
    }

    if (correo != _correoRegistrado) {
      setState(() {
        _mensajeError = 'Error: Dirección de correo no registrada.';
      });
      return;
    }

    if (_codigoEnviado) {
      setState(() {
        _mensajeError =
            'Error: Ya se ha enviado un código a la dirección proporcionada, para volver a enviar use el botón "Reenviar código".';
      });
      return;
    }

    await _mostrarCarga('Redirigiendo');

    setState(() {
      _codigoEnviado = true;
      _mensajeExito = 'Se ha enviado el código';
    });
  }

  Future<void> _reenviarCodigo() async {
    FocusScope.of(context).unfocus();

    final correo = _correoController.text.trim();

    setState(() {
      _limpiarMensajes();
    });

    if (correo.isEmpty) {
      setState(() {
        _mensajeError =
            'Error: Antes de reenviar el código debe proporcionar su correo institucional o con el que se registró.';
      });
      return;
    }

    if (correo != _correoRegistrado) {
      setState(() {
        _mensajeError = 'Error: Dirección de correo no registrada.';
      });
      return;
    }

    if (!_codigoEnviado) {
      setState(() {
        _mensajeError =
            'Error: Aún no se envía un código porque no se ha proporcionado una dirección de correo electrónico.';
      });
      return;
    }

    await _mostrarCarga('Redirigiendo');

    setState(() {
      _mensajeExito = 'Se ha reenviado el código';
    });
  }

  Future<void> _continuar() async {
    FocusScope.of(context).unfocus();

    final correo = _correoController.text.trim();
    final codigo = _codigoController.text.trim();

    setState(() {
      _limpiarMensajes();
    });

    if (correo.isEmpty) {
      setState(() {
        _mensajeError =
            'Error: Antes de continuar debe proporcionar su correo institucional.';
      });
      return;
    }

    if (correo != _correoRegistrado) {
      setState(() {
        _mensajeError = 'Error: Dirección de correo no registrada.';
      });
      return;
    }

    if (!_codigoEnviado) {
      setState(() {
        _mensajeError = 'Error: Aún no se envió un código.';
      });
      return;
    }

    if (codigo.isEmpty) {
      setState(() {
        _mensajeExito = 'Se ha enviado el código';
        _mensajeError = 'Error: No se ha proporcionado ningún código.';
      });
      return;
    }

    if (codigo != _codigoCorrecto) {
      setState(() {
        _mensajeExito = 'Se ha enviado el código';
        _mensajeError = 'Error: Código incorrecto, vuelva a intentar.';
      });
      return;
    }

    setState(() {
      _mensajeExito = 'Se ha enviado el código';
    });

    await _mostrarCarga('Redirigiendo');

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecuperarCuentaScreen(correo: correo),
      ),
    );
  }

  Widget _campoTexto({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool mostrarCheck = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6A6A6A),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF555B66)),
            suffixIcon: mostrarCheck
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            filled: true,
            fillColor: Colors.transparent,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF8A8A8A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF4A6C94), width: 1.4),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _botonPequeno({
    required String texto,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 140,
      height: 38,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFE8EAF0),
          foregroundColor: const Color(0xFF4A6C94),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(texto),
      ),
    );
  }

  Widget _botonGrande({
    required String texto,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 1,
          backgroundColor: const Color(0xFFE8EAF0),
          foregroundColor: const Color(0xFF4A6C94),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final correoConCheck = _correoController.text.trim().isNotEmpty;
    final codigoConCheck = _codigoController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Olvidé mi\ncontraseña',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 44),
              _campoTexto(
                label: 'Correo electrónico',
                controller: _correoController,
                hint: 'Correo electrónico',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                mostrarCheck: correoConCheck,
              ),
              const SizedBox(height: 14),
              _botonPequeno(
                texto: 'Enviar código',
                onPressed: _enviarCodigo,
              ),
              if (_mensajeExito.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  _mensajeExito,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 34),
              _campoTexto(
                label: 'Ingresar código',
                controller: _codigoController,
                hint: '###',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                mostrarCheck: codigoConCheck,
              ),
              const SizedBox(height: 14),
              _botonPequeno(
                texto: 'Reenviar código',
                onPressed: _reenviarCodigo,
              ),
              const SizedBox(height: 24),
              if (_mensajeError.isNotEmpty)
                Text(
                  _mensajeError,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 80),
              Row(
                children: [
                  Expanded(
                    child: _botonGrande(
                      texto: 'Atrás',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _botonGrande(
                      texto: 'Continuar',
                      onPressed: _continuar,
                    ),
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

class RecuperarCuentaScreen extends StatefulWidget {
  final String correo;

  const RecuperarCuentaScreen({
    super.key,
    required this.correo,
  });

  @override
  State<RecuperarCuentaScreen> createState() => _RecuperarCuentaScreenState();
}

class _RecuperarCuentaScreenState extends State<RecuperarCuentaScreen> {
  final TextEditingController _nuevaController = TextEditingController();
  final TextEditingController _confirmarController = TextEditingController();

  String _mensajeError = '';

  @override
  void dispose() {
    _nuevaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _mostrarCarga(String titulo) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Cargando',
      pageBuilder: (_, __, ___) {
        return Material(
          color: const Color(0xFFF3F4F8),
          child: _PantallaCarga(titulo: titulo),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _continuar() async {
    FocusScope.of(context).unfocus();

    final nueva = _nuevaController.text.trim();
    final confirmar = _confirmarController.text.trim();

    setState(() {
      _mensajeError = '';
    });

    if (nueva.isEmpty || confirmar.isEmpty) {
      setState(() {
        _mensajeError = 'Error: Debe completar ambos campos.';
      });
      return;
    }

    if (nueva.length < 6) {
      setState(() {
        _mensajeError =
            'Error: La nueva contraseña debe tener al menos 6 caracteres.';
      });
      return;
    }

    if (nueva != confirmar) {
      setState(() {
        _mensajeError = 'Error: Las contraseñas no coinciden.';
      });
      return;
    }

    await _mostrarCarga('Generando\ncontraseña');

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ContrasenaGeneradaScreen(correo: widget.correo),
      ),
    );
  }

  Widget _campoPassword({
    required String label,
    required TextEditingController controller,
  }) {
    final lleno = controller.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6A6A6A),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            hintText: '######',
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Color(0xFF555B66),
            ),
            suffixIcon:
                lleno ? const Icon(Icons.check, color: Colors.green) : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF8A8A8A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF4A6C94), width: 1.4),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _boton({
    required String texto,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 1,
          backgroundColor: const Color(0xFFE8EAF0),
          foregroundColor: const Color(0xFF4A6C94),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(texto),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Recuperar cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              _campoPassword(
                label: 'Ingrese nueva contraseña',
                controller: _nuevaController,
              ),
              const SizedBox(height: 24),
              _campoPassword(
                label: 'Confirmar contraseña',
                controller: _confirmarController,
              ),
              if (_mensajeError.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  _mensajeError,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 110),
              Row(
                children: [
                  Expanded(
                    child: _boton(
                      texto: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _boton(
                      texto: 'Continuar',
                      onPressed: _continuar,
                    ),
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

class ContrasenaGeneradaScreen extends StatelessWidget {
  final String correo;

  const ContrasenaGeneradaScreen({
    super.key,
    required this.correo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'Contraseña\ngenerada\nexitosamente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 34),
              const Text(
                'Se ha actualizado la\ncontraseña de la cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                correo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 1,
                    backgroundColor: const Color(0xFFE8EAF0),
                    foregroundColor: const Color(0xFF4A6C94),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text('Entendido'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PantallaCarga extends StatelessWidget {
  final String titulo;

  const _PantallaCarga({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 46),
              const SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(strokeWidth: 6),
              ),
              const SizedBox(height: 36),
              const Text(
                'Espere unos momentos.....',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}