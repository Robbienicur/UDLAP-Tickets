import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/app_theme.dart';

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
          color: AppColors.background,
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
    setState(_limpiarMensajes);

    if (correo.isEmpty) {
      setState(() {
        _mensajeError =
            'Antes de enviar el código debe proporcionar su correo institucional.';
      });
      return;
    }

    if (correo != _correoRegistrado) {
      setState(() {
        _mensajeError = 'Dirección de correo no registrada.';
      });
      return;
    }

    if (_codigoEnviado) {
      setState(() {
        _mensajeError =
            'Ya se ha enviado un código. Use "Reenviar código" si lo necesita.';
      });
      return;
    }

    await _mostrarCarga('Enviando código');

    setState(() {
      _codigoEnviado = true;
      _mensajeExito = 'Se ha enviado el código a tu correo';
    });
  }

  Future<void> _reenviarCodigo() async {
    FocusScope.of(context).unfocus();
    final correo = _correoController.text.trim();
    setState(_limpiarMensajes);

    if (correo.isEmpty) {
      setState(() {
        _mensajeError =
            'Proporciona tu correo institucional antes de reenviar el código.';
      });
      return;
    }

    if (correo != _correoRegistrado) {
      setState(() {
        _mensajeError = 'Dirección de correo no registrada.';
      });
      return;
    }

    if (!_codigoEnviado) {
      setState(() {
        _mensajeError =
            'Aún no se envía un código porque no se ha proporcionado un correo.';
      });
      return;
    }

    await _mostrarCarga('Reenviando código');

    setState(() {
      _mensajeExito = 'Se ha reenviado el código';
    });
  }

  Future<void> _continuar() async {
    FocusScope.of(context).unfocus();
    final correo = _correoController.text.trim();
    final codigo = _codigoController.text.trim();
    setState(_limpiarMensajes);

    if (correo.isEmpty) {
      setState(() {
        _mensajeError = 'Proporciona tu correo institucional.';
      });
      return;
    }

    if (correo != _correoRegistrado) {
      setState(() {
        _mensajeError = 'Dirección de correo no registrada.';
      });
      return;
    }

    if (!_codigoEnviado) {
      setState(() {
        _mensajeError = 'Aún no se envió un código.';
      });
      return;
    }

    if (codigo.isEmpty) {
      setState(() {
        _mensajeError = 'No se ha proporcionado ningún código.';
      });
      return;
    }

    if (codigo != _codigoCorrecto) {
      setState(() {
        _mensajeError = 'Código incorrecto, vuelve a intentar.';
      });
      return;
    }

    await _mostrarCarga('Verificando');

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecuperarCuentaScreen(correo: correo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIcons.arrowLeft()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Olvidé mi\ncontraseña',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Te enviaremos un código a tu correo institucional',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'estudiante@udlap.mx',
                  prefixIcon: PhosphorIcon(PhosphorIcons.envelope()),
                  suffixIcon: _correoController.text.trim().isNotEmpty
                      ? PhosphorIcon(
                          PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                          color: AppColors.success,
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _enviarCodigo,
                  icon: PhosphorIcon(
                    PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.bold),
                    size: 18,
                  ),
                  label: const Text('Enviar código'),
                ),
              ),
              if (_mensajeExito.isNotEmpty) ...[
                const SizedBox(height: 12),
                _MensajeBanner(
                  texto: _mensajeExito,
                  color: AppColors.success,
                  icon: Icons.check_circle_outline,
                ),
              ],
              const SizedBox(height: 28),
              TextField(
                controller: _codigoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Ingresar código',
                  hintText: '###',
                  prefixIcon: const Icon(Icons.numbers),
                  suffixIcon: _codigoController.text.trim().isNotEmpty
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _reenviarCodigo,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reenviar código'),
                ),
              ),
              if (_mensajeError.isNotEmpty) ...[
                const SizedBox(height: 16),
                _MensajeBanner(
                  texto: _mensajeError,
                  color: AppColors.error,
                  icon: Icons.error_outline,
                ),
              ],
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Atrás'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _continuar,
                        child: const Text('Continuar'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class RecuperarCuentaScreen extends StatefulWidget {
  final String correo;

  const RecuperarCuentaScreen({super.key, required this.correo});

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
          color: AppColors.background,
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
        _mensajeError = 'Debes completar ambos campos.';
      });
      return;
    }

    if (nueva.length < 6) {
      setState(() {
        _mensajeError = 'La nueva contraseña debe tener al menos 6 caracteres.';
      });
      return;
    }

    if (nueva != confirmar) {
      setState(() {
        _mensajeError = 'Las contraseñas no coinciden.';
      });
      return;
    }

    await _mostrarCarga('Generando contraseña');

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ContrasenaGeneradaScreen(correo: widget.correo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIcons.arrowLeft()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Recuperar cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crea una nueva contraseña segura',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 36),
              TextField(
                controller: _nuevaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                  hintText: '••••••',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmarController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                  hintText: '••••••',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (_mensajeError.isNotEmpty) ...[
                const SizedBox(height: 16),
                _MensajeBanner(
                  texto: _mensajeError,
                  color: AppColors.error,
                  icon: Icons.error_outline,
                ),
              ],
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _continuar,
                        child: const Text('Continuar'),
                      ),
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

  const ContrasenaGeneradaScreen({super.key, required this.correo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Contraseña\ngenerada\nexitosamente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Se ha actualizado la contraseña de la cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                correo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
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
                  child: const Text('Entendido'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _MensajeBanner extends StatelessWidget {
  final String texto;
  final Color color;
  final IconData icon;

  const _MensajeBanner({
    required this.texto,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 36),
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Espera unos momentos…',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
