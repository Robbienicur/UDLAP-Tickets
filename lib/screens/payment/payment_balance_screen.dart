import 'package:flutter/material.dart';
import '../tickets/recargar_saldo_screen.dart';
import 'payment_success_screen.dart';

const Color authBackground = Color(0xFFF3F4F8);
const Color authPrimary = Color(0xFF4A6C94);
const Color authSecondary = Color(0xFFE8EAF0);
const Color authLabel = Color(0xFF6A6A6A);

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

class PaymentBalanceScreen extends StatelessWidget {
  final int total;
  final int saldoDisponible;

  const PaymentBalanceScreen({
    super.key,
    required this.total,
    required this.saldoDisponible,
  });

  @override
  Widget build(BuildContext context) {
    int saldoRestante = saldoDisponible - total;
    bool saldoSuficiente = saldoDisponible >= total;

    return Scaffold(
      backgroundColor: authBackground,
      appBar: AppBar(
        title: const Text("Saldo"),
        backgroundColor: authBackground,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            // SALDO DISPONIBLE
            const Text(
              "Saldo disponible",
              style: TextStyle(color: authLabel),
            ),
            const SizedBox(height: 5),
            Text(
              "\$$saldoDisponible",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 25),

            // SALDO EXIGIBLE
            const Text(
              "Saldo exigible",
              style: TextStyle(color: authLabel),
            ),
            const SizedBox(height: 5),
            Text(
              "\$$total",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            const Divider(thickness: 2),

            const SizedBox(height: 20),

            // SALDO RESTANTE
            const Text(
              "Saldo restante",
              style: TextStyle(color: authLabel),
            ),
            const SizedBox(height: 5),
            Text(
              "\$$saldoRestante",
              style: const TextStyle(fontSize: 18),
            ),

            // MENSAJE DE ERROR
            if (!saldoSuficiente)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "Saldo insuficiente",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const Spacer(),

            // BOTÓN RECARGAR
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: authSecondary,
                  foregroundColor: authPrimary,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecargarSaldoScreen(),
                    ),
                  );
                },
                child: const Text("Recargar"),
              ),
            ),

            const SizedBox(height: 30),

            // BOTONES INFERIORES
            Row(
              children: [

                Expanded(
                  child: ElevatedButton(
                    style: paymentOutlinedButtonStyle(),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancelar"),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: saldoSuficiente
                          ? authSecondary
                          : Colors.grey.shade400,
                      foregroundColor: saldoSuficiente ? authPrimary : Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: saldoSuficiente
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Pago realizado con saldo")),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaymentSuccessScreen(),
                              ),
                            );
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("No tienes saldo suficiente")),
                            );
                          },
                    child: const Text("Pagar"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}