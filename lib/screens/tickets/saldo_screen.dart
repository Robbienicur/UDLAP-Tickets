import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'recargar_saldo_screen.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class SaldoScreen extends StatelessWidget {
  final int cantidadBoletos;

  const SaldoScreen({super.key, required this.cantidadBoletos});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final double saldoDisponible = apiService.saldo;
    const double precioBoleto = 25.00;
    final double saldoExigible = cantidadBoletos * precioBoleto;
    final double saldoRestante = saldoDisponible - saldoExigible;
    final bool suficiente = saldoRestante >= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagar con saldo'),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.wallet(),
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Saldo disponible',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '\$${saldoDisponible.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    _LineaDetalle(
                      etiqueta: 'A pagar',
                      valor: '\$${saldoExigible.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    _LineaDetalle(
                      etiqueta: 'Saldo restante',
                      valor: '\$${saldoRestante.toStringAsFixed(2)}',
                      destacado: true,
                      esError: !suficiente,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
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
              const Spacer(),
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
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: suficiente
                            ? () {
                                HapticFeedback.mediumImpact();
                                Navigator.pop(context, true);
                              }
                            : null,
                        child: Text(suficiente ? 'Pagar' : 'Saldo Insuficiente'),
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

class _LineaDetalle extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final bool destacado;
  final bool esError;

  const _LineaDetalle({
    required this.etiqueta,
    required this.valor,
    this.destacado = false,
    this.esError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = esError
        ? AppColors.error
        : (destacado ? AppColors.accentDark : AppColors.textPrimary);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: destacado ? 22 : 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
