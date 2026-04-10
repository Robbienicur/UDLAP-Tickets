import 'package:flutter/material.dart';
import 'recargar_saldo_screen.dart';

class SaldoScreen extends StatelessWidget {
  final int cantidadBoletos;

  const SaldoScreen({super.key, required this.cantidadBoletos});

  @override
  Widget build(BuildContext context) {
    double saldoDisponible = 150.00;
    double precioBoleto = 25.00;
    double saldoExigible = cantidadBoletos * precioBoleto;
    double saldoRestante = saldoDisponible - saldoExigible;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Saldo',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Saldo disponible',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                '\$${saldoDisponible.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 25),
              const Text(
                'Saldo exigible',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                '\$${saldoExigible.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              const Text(
                'Saldo restante',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                '\$${saldoRestante.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecargarSaldoScreen(),
                      ),
                    );
                  },
                  child: const Text('Recargar'),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('Pagar'),
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
