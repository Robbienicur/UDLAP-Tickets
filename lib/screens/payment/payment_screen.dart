import 'package:flutter/material.dart';
import 'payment_card_screen.dart';
import 'payment_balance_screen.dart';
import 'payment_other_methods_screen.dart';

const Color authBackground = Color(0xFFF3F4F8);
const Color authPrimary = Color(0xFF4A6C94);
const Color authSecondary = Color(0xFFE8EAF0);
const Color authBorder = Color(0xFF8A8A8A);
const Color authIcon = Color(0xFF555B66);
const Color authLabel = Color(0xFF6A6A6A);

ButtonStyle paymentPrimaryButtonStyle() {
  return ElevatedButton.styleFrom(
    elevation: 1,
    backgroundColor: authSecondary,
    foregroundColor: authPrimary,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    ),
  );
}

ButtonStyle paymentOutlinedButtonStyle() {
  return ElevatedButton.styleFrom(
    elevation: 1,
    backgroundColor: authSecondary,
    foregroundColor: authPrimary,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    ),
  );
}

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
  String metodoSeleccionado = "";
  int saldoActual = 100;

  IconData _iconoMetodo(String id) {
    switch (id) {
      case "tarjeta":
        return Icons.credit_card_outlined;
      case "saldo":
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.more_horiz;
    }
  }

  Future<void> _continuarConMetodoSeleccionado() async {
    if (metodoSeleccionado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona un metodo de pago")),
      );
      return;
    }

    dynamic resultado;

    if (metodoSeleccionado == "tarjeta") {
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

    if (metodoSeleccionado == "saldo") {
      if (saldoActual < widget.total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Saldo insuficiente")),
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

    if (metodoSeleccionado == "otros") {
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

  Widget metodoPago(String id, String texto) {
    bool seleccionado = metodoSeleccionado == id;

    return GestureDetector(
      onTap: () async {
        setState(() {
          metodoSeleccionado = id;
        });

        await _continuarConMetodoSeleccionado();
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: seleccionado ? authSecondary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: seleccionado ? authPrimary : authBorder,
            width: seleccionado ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _iconoMetodo(id),
              color: seleccionado ? authPrimary : authIcon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  color: seleccionado ? authPrimary : authIcon,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (seleccionado)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: authBackground,

      appBar: AppBar(
        title: const Text("Confirmación"),
        backgroundColor: authBackground,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "${widget.cantidad} boleto${widget.cantidad == 1 ? '' : 's'}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Importe: \$${widget.total}",
                          style: const TextStyle(
                            color: authLabel,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Saldo actual: \$$saldoActual",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Selecciona método de pago",
                    style: TextStyle(
                      color: authLabel,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  metodoPago("tarjeta", "Tarjeta"),
                  metodoPago("saldo", "Saldo"),
                  metodoPago("otros", "Otros"),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          style: paymentOutlinedButtonStyle(),
                          child: const Text("Cancelar"),
                        ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _continuarConMetodoSeleccionado,
                            style: paymentPrimaryButtonStyle(),
                            child: const Text("Continuar"),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}