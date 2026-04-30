import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'payment_success_screen.dart';
import '../../theme/app_theme.dart';

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
        const SnackBar(content: Text('Completa correctamente los campos')),
      );
      return;
    }

    if (!aceptoTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentSuccessScreen(),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required Function(String) validator,
    required List<TextInputFormatter> formatters,
    required TextInputType type,
    required bool isValid,
    IconData? icon,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: type,
          inputFormatters: formatters,
          onChanged: validator,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon),
            suffixIcon: controller.text.isNotEmpty
                ? Icon(
                    isValid ? Icons.check_circle : Icons.error_outline,
                    color: isValid ? AppColors.success : AppColors.error,
                    size: 20,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago con tarjeta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
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
                            '${widget.cantidad} ${widget.cantidad == 1 ? "boleto" : "boletos"}',
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
                      '\$${widget.total}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildField(
                label: 'Número de tarjeta',
                controller: cardController,
                hint: '1234 5678 9012 3456',
                type: TextInputType.number,
                isValid: isCardValid,
                validator: validateCard,
                icon: Icons.credit_card,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      label: 'Fecha',
                      controller: expiryController,
                      hint: 'MM/AA',
                      type: TextInputType.number,
                      isValid: isExpiryValid,
                      validator: validateExpiry,
                      icon: Icons.calendar_today_outlined,
                      formatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                        LengthLimitingTextInputFormatter(5),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildField(
                      label: 'CVV',
                      controller: cvvController,
                      hint: '123',
                      type: TextInputType.number,
                      isValid: isCvvValid,
                      validator: validateCvv,
                      icon: Icons.lock_outline,
                      obscure: true,
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: aceptoTerminos,
                    onChanged: (v) {
                      setState(() => aceptoTerminos = v ?? false);
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'He leído y acepto los términos',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: continuar,
                        child: const Text('Pagar'),
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
