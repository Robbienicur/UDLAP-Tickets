import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'pago_tarjeta_screen.dart';
import 'saldo_screen.dart';
import 'recargar_saldo_screen.dart';
import '../payment/payment_other_methods_screen.dart';
import '../../theme/app_theme.dart';

class ConfirmacionScreen extends StatelessWidget {
  final int cantidadBoletos;

  const ConfirmacionScreen({super.key, required this.cantidadBoletos});

  static const double _precioBoleto = 25.0;

  @override
  Widget build(BuildContext context) {
    final total = cantidadBoletos * _precioBoleto;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar compra'),
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
              _ResumenCard(cantidad: cantidadBoletos, total: total),
              const SizedBox(height: 24),
              Text('Método de pago', style: AppText.title()),
              const SizedBox(height: 12),
              _MetodoPagoTile(
                icon: PhosphorIcons.creditCard(),
                titulo: 'Tarjeta',
                subtitulo: 'Crédito o débito',
                onTap: () async {
                  HapticFeedback.selectionClick();
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PagoTarjetaScreen(),
                    ),
                  );
                  if (result == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
              ),
              const SizedBox(height: 10),
              _MetodoPagoTile(
                icon: PhosphorIcons.wallet(),
                titulo: 'Saldo',
                subtitulo: 'Pagar con saldo disponible',
                onTap: () async {
                  HapticFeedback.selectionClick();
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SaldoScreen(
                        cantidadBoletos: cantidadBoletos,
                      ),
                    ),
                  );
                  if (result == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
              ),
              const SizedBox(height: 10),
              _MetodoPagoTile(
                icon: PhosphorIcons.dotsThree(PhosphorIconsStyle.bold),
                titulo: 'Otros métodos',
                subtitulo: 'Apple Pay, Google Pay, PayPal',
                onTap: () async {
                  HapticFeedback.selectionClick();
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentOtherMethodsScreen(
                        cantidad: cantidadBoletos,
                        total: total.toInt(),
                      ),
                    ),
                  );
                  if (result == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
              ),
              const Spacer(),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecargarSaldoScreen(),
                      ),
                    );
                  },
                  icon: PhosphorIcon(
                    PhosphorIcons.plusCircle(PhosphorIconsStyle.bold),
                    size: 18,
                  ),
                  label: const Text('Recargar saldo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final int cantidad;
  final double total;

  const _ResumenCard({required this.cantidad, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen',
            style: AppText.label(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$cantidad ${cantidad == 1 ? "boleto" : "boletos"}',
                style: AppText.h2(color: Colors.white),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: AppText.priceLarge(color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetodoPagoTile extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _MetodoPagoTile({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
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
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PhosphorIcon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: AppText.title()),
                    const SizedBox(height: 2),
                    Text(subtitulo, style: AppText.caption()),
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
}
