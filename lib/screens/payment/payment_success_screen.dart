import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/app_theme.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: PhosphorIcon(
                  PhosphorIcons.check(PhosphorIconsStyle.bold),
                  color: AppColors.primary,
                  size: 64,
                ),
              )
                  .animate()
                  .scale(
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0.4, 0.4),
                    end: const Offset(1, 1),
                  )
                  .then()
                  .shimmer(
                    duration: 1200.ms,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
              const SizedBox(height: 32),
              Text('¡Pago exitoso!', style: AppText.h1())
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 12),
              Text(
                'Tu pago se ha realizado correctamente.\nYa puedes ver tus boletos.',
                textAlign: TextAlign.center,
                style: AppText.body(color: AppColors.textSecondary),
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context, true);
                  },
                  child: const Text('Continuar'),
                ),
              ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideY(
                    begin: 0.3,
                    end: 0,
                  ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
