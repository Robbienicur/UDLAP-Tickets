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
        title: const Text("Pago con Apple Pay"),
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
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Simulación tarjeta Apple Pay",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text("Acercar al lector"),
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