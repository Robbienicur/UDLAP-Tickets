import 'package:flutter/material.dart';
import 'payment_card_screen.dart';
import 'payment_balance_screen.dart';
import 'payment_other_methods_screen.dart';
import '../../theme/app_theme.dart';

class PaymentScreen extends StatefulWidget {
  final int cantidad;
  final int total;

  const PaymentScreen({
    super.key,
    required this.cantidad,
    required this.total,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String metodoSeleccionado = '';
  int saldoActual = 100;

  IconData _iconoMetodo(String id) {
    switch (id) {
      case 'tarjeta':
        return Icons.credit_card_outlined;
      case 'saldo':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  Future<void> _continuarConMetodoSeleccionado() async {
    if (metodoSeleccionado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un método de pago')),
      );
      return;
    }

    dynamic resultado;

    if (metodoSeleccionado == 'tarjeta') {
      resultado = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentCardScreen(
            cantidad: widget.cantidad,
            total: widget.total,
          ),
        ),
      );
    }

    if (metodoSeleccionado == 'saldo') {
      if (saldoActual < widget.total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saldo insuficiente')),
        );
        return;
      }

      resultado = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentBalanceScreen(
            total: widget.total,
            saldoDisponible: saldoActual,
          ),
        ),
      );
    }

    if (metodoSeleccionado == 'otros') {
      resultado = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentOtherMethodsScreen(
            cantidad: widget.cantidad,
            total: widget.total,
          ),
        ),
      );
    }

    if (resultado == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Widget _metodoPago(String id, String texto, String subtitulo) {
    final seleccionado = metodoSeleccionado == id;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: seleccionado ? AppColors.primaryContainer : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            setState(() => metodoSeleccionado = id);
            await _continuarConMetodoSeleccionado();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: seleccionado ? AppColors.primary : AppColors.divider,
                width: seleccionado ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: seleccionado
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconoMetodo(id),
                    color: seleccionado
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        texto,
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
                if (seleccionado)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar compra'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                        Text(
                          '${widget.cantidad} ${widget.cantidad == 1 ? "boleto" : "boletos"}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Importe',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '\$${widget.total}',
                              style: const TextStyle(
                                fontSize: 26,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Saldo actual: \$$saldoActual',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Método de pago',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _metodoPago('tarjeta', 'Tarjeta', 'Crédito o débito'),
                  _metodoPago('saldo', 'Saldo', 'Pagar con saldo disponible'),
                  _metodoPago(
                    'otros',
                    'Otros',
                    'Apple Pay, Google Pay, PayPal',
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _continuarConMetodoSeleccionado,
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
        ),
      ),
    );
  }
}
