import 'package:flutter/material.dart';
import 'google_pay_screen.dart';
import 'paypal_screen.dart';
import 'apple_pay_screen.dart';

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

class PaymentOtherMethodsScreen extends StatelessWidget {
  final int cantidad;
  final int total;

  const PaymentOtherMethodsScreen({
    super.key,
    required this.cantidad,
    required this.total,
  });

  Widget metodoBoton(
    String texto,
    BuildContext context,
    Widget pantallaDestino,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          backgroundColor: authSecondary,
          foregroundColor: authPrimary,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: () async {
          final bool? resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pantallaDestino),
          );

          // si el pago fue exitoso, regresa a pantalla anterior
          if (resultado == true) {
            Navigator.pop(context, true);
          }
        },
        child: Text(
          texto,
              style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: authBackground,

      appBar: AppBar(
        title: const Text("Otros Métodos de Pago"),
        backgroundColor: authBackground,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            Text("$cantidad boleto(s) a comprar"),
            const SizedBox(height: 5),

            Text(
              "Importe: \$$total",
              style: const TextStyle(
                color: authLabel,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 40),

            // GOOGLE PAY
            metodoBoton(
              "Google Pay",
              context,
              GooglePayScreen(
                cantidad: cantidad,
                total: total,
              ),
            ),

            // APPLE PAY
            metodoBoton(
              "Apple Pay",
              context,
              ApplePayScreen(
                cantidad: cantidad,
                total: total,
              ),
            ),

            // PAYPAL
            metodoBoton(
              "PayPal",
              context,
              PaypalScreen(
                cantidad: cantidad,
                total: total,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                style: paymentOutlinedButtonStyle(),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancelar"),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}