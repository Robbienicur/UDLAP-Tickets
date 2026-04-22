import 'package:flutter/material.dart';

class MisBoletosScreen extends StatefulWidget {
  const MisBoletosScreen({super.key});

  @override
  State<MisBoletosScreen> createState() => _MisBoletosScreenState();
}

class _MisBoletosScreenState extends State<MisBoletosScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Boletos'),
      ),
      body: const Center(
        child: Text('Contenido de Mis Boletos'),
      ),
    );
  }
}
