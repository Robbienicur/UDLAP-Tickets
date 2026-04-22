import 'package:flutter/material.dart';
import 'payment_success_screen.dart';

const Color authBackground = Color(0xFFF3F4F8);
const Color authPrimary = Color(0xFF4A6C94);
const Color authSecondary = Color(0xFFE8EAF0);
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

class PaypalScreen extends StatefulWidget {
  final int cantidad;
  final int total;

  const PaypalScreen({
    super.key,
    required this.cantidad,
    required this.total,
  });

  @override
  State<PaypalScreen> createState() => _PaypalScreenState();
}

class _PaypalScreenState extends State<PaypalScreen> {
  bool aceptado = false;
  bool cargando = false;

  Future<void> procesarPago() async {
    setState(() => cargando = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => cargando = false);

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const PaymentSuccessScreen(),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pago con PayPal"),
        backgroundColor: authBackground,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: authBackground,

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text("${widget.cantidad} boletos a comprar"),
                const SizedBox(height: 5),
                Text("Importe: \$${widget.total}",
                    style: const TextStyle(
                      color: authLabel,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    )),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Column(
                    children: [
                      Text("PayPal"),
                      SizedBox(height: 10),
                      Text("Enviar pagos"),
                      Text("Recibir pagos"),
                    ],
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    Checkbox(
                      value: aceptado,
                      onChanged: (v) {
                        setState(() => aceptado = v!);
                      },
                    ),
                    const Expanded(
                      child: Text(
                          "He leído y acepto los términos y condiciones"),
                    )
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
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
                          onPressed: aceptado ? procesarPago : null,
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

          if (cargando)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            )
        ],
      ),
    );
  }
}