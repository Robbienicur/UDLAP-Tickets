import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/app_theme.dart';

class PagoTarjetaScreen extends StatefulWidget {
  const PagoTarjetaScreen({super.key});

  @override
  State<PagoTarjetaScreen> createState() => _PagoTarjetaScreenState();
}

class _PagoTarjetaScreenState extends State<PagoTarjetaScreen> {
  final _nombreController = TextEditingController();
  final _numeroController = TextEditingController();
  final _fechaController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _numeroController.dispose();
    _fechaController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago con tarjeta'),
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIcons.arrowLeft()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 170,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TARJETA',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        PhosphorIcon(
                          PhosphorIcons.wifiHigh(),
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                    Text(
                      _numeroController.text.isEmpty
                          ? '•••• •••• •••• ••••'
                          : _numeroController.text,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _nombreController.text.isEmpty
                              ? 'NOMBRE'
                              : _nombreController.text.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _fechaController.text.isEmpty
                              ? 'MM/AA'
                              : _fechaController.text,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nombreController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Nombre del titular',
                  prefixIcon: PhosphorIcon(PhosphorIcons.user()),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _numeroController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Número de tarjeta',
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: PhosphorIcon(PhosphorIcons.creditCard()),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fechaController,
                      keyboardType: TextInputType.datetime,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'MM/AA',
                        prefixIcon: PhosphorIcon(PhosphorIcons.calendar()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        prefixIcon: PhosphorIcon(PhosphorIcons.lock()),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(context);
                        },
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context, true);
                        },
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
