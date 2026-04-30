import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'google_pay_screen.dart';
import 'paypal_screen.dart';
import 'apple_pay_screen.dart';
import '../../theme/app_theme.dart';

class PaymentOtherMethodsScreen extends StatelessWidget {
  final int cantidad;
  final int total;

  const PaymentOtherMethodsScreen({
    super.key,
    required this.cantidad,
    required this.total,
  });

  Widget _metodoBoton({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String titulo,
    required String subtitulo,
    required Widget pantallaDestino,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          HapticFeedback.selectionClick();
          final bool? resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pantallaDestino),
          );
          if (resultado == true && context.mounted) {
            Navigator.pop(context, true);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PhosphorIcon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PhosphorIcon(
                PhosphorIcons.caretRight(),
                size: 14,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Otros métodos de pago'),
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIcons.arrowLeft()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ImporteHeader(cantidad: cantidad, total: total),
              const SizedBox(height: 24),
              _metodoBoton(
                context: context,
                icon: PhosphorIcons.googleLogo(PhosphorIconsStyle.bold),
                iconColor: const Color(0xFF4285F4),
                titulo: 'Google Pay',
                subtitulo: 'Paga con tu cuenta de Google',
                pantallaDestino: GooglePayScreen(
                  cantidad: cantidad,
                  total: total,
                ),
              ),
              const SizedBox(height: 10),
              _metodoBoton(
                context: context,
                icon: PhosphorIcons.appleLogo(PhosphorIconsStyle.fill),
                iconColor: AppColors.textPrimary,
                titulo: 'Apple Pay',
                subtitulo: 'Paga con Apple Pay',
                pantallaDestino: ApplePayScreen(
                  cantidad: cantidad,
                  total: total,
                ),
              ),
              const SizedBox(height: 10),
              _metodoBoton(
                context: context,
                icon: PhosphorIcons.paypalLogo(PhosphorIconsStyle.bold),
                iconColor: const Color(0xFF003087),
                titulo: 'PayPal',
                subtitulo: 'Paga con tu cuenta PayPal',
                pantallaDestino: PaypalScreen(
                  cantidad: cantidad,
                  total: total,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
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
