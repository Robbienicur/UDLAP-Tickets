import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'payment_success_screen.dart';

const Color authBackground = Color(0xFFF3F4F8);
const Color authPrimary = Color(0xFF4A6C94);
const Color authSecondary = Color(0xFFE8EAF0);
const Color authBorder = Color(0xFF8A8A8A);
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

class PaymentCardScreen extends StatefulWidget {
  final int cantidad;
  final int total;

  const PaymentCardScreen({
    super.key,
    required this.cantidad,
    required this.total,
  });

  @override
  State<PaymentCardScreen> createState() => _PaymentCardScreenState();
}

class _PaymentCardScreenState extends State<PaymentCardScreen> {
  bool aceptoTerminos = false;

  final TextEditingController cardController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  bool isCardValid = false;
  bool isExpiryValid = false;
  bool isCvvValid = false;

  void validateCard(String value) {
    setState(() {
      isCardValid = RegExp(r'^[0-9]{16}$').hasMatch(value);
    });
  }

  void validateExpiry(String value) {
    setState(() {
      isExpiryValid =
          RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(value);
    });
  }

  void validateCvv(String value) {
    setState(() {
      isCvvValid = RegExp(r'^[0-9]{3,4}$').hasMatch(value);
    });
  }

  void continuar() {
    if (!isCardValid || !isExpiryValid || !isCvvValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa correctamente los campos")),
      );
      return;
    }

    if (!aceptoTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes aceptar términos")),
      );
      return;
    }

    // IR A PANTALLA DE PAGO EXITOSO
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentSuccessScreen(),
      ),
    );
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required Function(String) validator,
    required List<TextInputFormatter> formatters,
    required TextInputType type,
    required bool isValid,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: authLabel,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (controller.text.isNotEmpty)
              Icon(
                isValid ? Icons.check_circle : Icons.error,
                color: isValid ? Colors.green : Colors.red,
                size: 20,
              ),
          ],
        ),

        TextField(
          controller: controller,
          keyboardType: type,
          inputFormatters: formatters,
          onChanged: validator,
          decoration: InputDecoration(
            hintText: hint,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: authBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: authPrimary, width: 1.4),
            ),
          ),
        ),

        const SizedBox(height: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: authBackground,

      appBar: AppBar(
        title: const Text("Pago con tarjeta"),
        backgroundColor: authBackground,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Text(
              "${widget.cantidad} boleto${widget.cantidad == 1 ? '' : 's'}",
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "Importe: \$${widget.total}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: authLabel,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),

            buildField(
              label: "Número de tarjeta",
              controller: cardController,
              hint: "1234567890123456",
              type: TextInputType.number,
              isValid: isCardValid,
              validator: validateCard,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
            ),

            buildField(
              label: "Fecha",
              controller: expiryController,
              hint: "MM/AA",
              type: TextInputType.number,
              isValid: isExpiryValid,
              validator: validateExpiry,
              formatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                LengthLimitingTextInputFormatter(5),
              ],
            ),

            buildField(
              label: "CVV",
              controller: cvvController,
              hint: "123",
              type: TextInputType.number,
              isValid: isCvvValid,
              validator: validateCvv,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ),

            Row(
              children: [
                Checkbox(
                  value: aceptoTerminos,
                  onChanged: (v) {
                    setState(() => aceptoTerminos = v ?? false);
                  },
                  activeColor: authPrimary,
                ),
                const Expanded(
                  child: Text("He leído y acepto los términos"),
                ),
              ],
            ),

            const Spacer(),

            // BOTONES
            Row(
              children: [

                // CANCELAR
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: paymentOutlinedButtonStyle(),
                    child: const Text(
                      "Cancelar",
                    ),
                  ),
                  ),
                ),

                const SizedBox(width: 16),

                // CONTINUAR
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: continuar,
                      style: paymentPrimaryButtonStyle(),
                      child: const Text(
                        "Continuar",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}