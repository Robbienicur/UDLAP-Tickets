import 'package:flutter/material.dart';
import 'payment_success_screen.dart';
import '../../theme/app_theme.dart';

class ApplePayScreen extends StatefulWidget {
  final int cantidad;
  final int total;

  const ApplePayScreen({
    super.key,
    required this.cantidad,
    required this.total,
  });

  @override
  State<ApplePayScreen> createState() => _ApplePayScreenState();
}

class _ApplePayScreenState extends State<ApplePayScreen> {
  bool aceptado = false;
  bool cargando = false;

  Future<void> procesarPago() async {
    setState(() => cargando = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => cargando = false);

    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentSuccessScreen(),
      ),
    );

    if (!mounted) return;
    if (ok == true) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago con Apple Pay'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ImporteHeader(
                    cantidad: widget.cantidad,
                    total: widget.total,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.apple_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Pay',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text(
                      'Acerca tu dispositivo al lector',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _CheckTerminos(
                    aceptado: aceptado,
                    onChanged: (v) => setState(() => aceptado = v ?? false),
                  ),
                  const SizedBox(height: 12),
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
                            onPressed: aceptado ? procesarPago : null,
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
          if (cargando)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImporteHeader extends StatelessWidget {
  final int cantidad;
  final int total;

  const _ImporteHeader({required this.cantidad, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$cantidad ${cantidad == 1 ? "boleto" : "boletos"}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Importe a pagar',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$$total',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckTerminos extends StatelessWidget {
  final bool aceptado;
  final ValueChanged<bool?> onChanged;

  const _CheckTerminos({required this.aceptado, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: aceptado, onChanged: onChanged),
        const Expanded(
          child: Text(
            'He leído y acepto los términos y condiciones',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
