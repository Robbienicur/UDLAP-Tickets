import 'package:flutter/material.dart';
import 'confirmacion_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final int _cantidadBoletos = 0;
  int _boletosComprar = 1;

  List<Widget> _buildPages() {
    return [
      // Inicio
      const Center(
        child: Text(
          'Inicio',
          style: TextStyle(fontSize: 24),
        ),
      ),
      // Mis Boletos
      _buildBoletosPage(),
      // Mi Perfil
      const Center(
        child: Text(
          'Mi Perfil',
          style: TextStyle(fontSize: 24),
        ),
      ),
    ];
  }

  Widget _buildBoletosPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis Boletos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tienes: $_cantidadBoletos',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          const Text(
            'Comprar Boletos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (_boletosComprar > 1) {
                    setState(() {
                      _boletosComprar--;
                    });
                  }
                },
                icon: const Icon(Icons.remove),
              ),
              Text(
                '$_boletosComprar',
                style: const TextStyle(fontSize: 20),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _boletosComprar++;
                  });
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmacionScreen(
                      cantidadBoletos: _boletosComprar,
                    ),
                  ),
                );
              },
              child: const Text('Comprar'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildPages()[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Mis Boletos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mi Perfil',
          ),
        ],
      ),
    );
  }
}
