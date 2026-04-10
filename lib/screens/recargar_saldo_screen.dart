import 'dart:math';
import 'package:flutter/material.dart';

class RecargarSaldoScreen extends StatelessWidget {
  const RecargarSaldoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                'Recargar Saldo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 300,
                height: 100,
                child: CustomPaint(
                  painter: _BarcodePainter(),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'AB12345678910',
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 30,
                    ),
                  ),
                  child: const Text('Atrás'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final random = Random(42);
    double x = 0;
    while (x < size.width) {
      double barWidth = (random.nextInt(3) + 1).toDouble();
      canvas.drawRect(
        Rect.fromLTWH(x, 0, barWidth, size.height),
        paint,
      );
      x += barWidth + (random.nextInt(3) + 1).toDouble();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
