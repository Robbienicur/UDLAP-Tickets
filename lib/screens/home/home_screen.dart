import 'package:flutter/material.dart';
import '../tickets/confirmacion_screen.dart';
import '../auth/login_screen.dart';

class Boleto {
  final String id;
  String estado;

  Boleto({required this.id, this.estado = 'Disponible'});
}

class HomeScreen extends StatefulWidget {
  final bool esInvitado;

  const HomeScreen({super.key, this.esInvitado = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Boleto> _misBoletos = [];
  int _boletosComprar = 1;

  int get _cantidadDisponibles =>
      _misBoletos.where((b) => b.estado == 'Disponible').length;

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
      _buildPerfilPage(),
    ];
  }

  Widget _buildPerfilPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mi Perfil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person, size: 40),
              title: Text(widget.esInvitado ? 'Invitado' : 'Estudiante UDLAP'),
              subtitle: Text(widget.esInvitado
                  ? 'Sesión de invitado'
                  : 'correo@udlap.mx'),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Términos y Condiciones'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Términos y Condiciones'),
                  content: const Text(
                      'Aquí irán los términos y condiciones de uso de la aplicación.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Ayuda'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Ayuda'),
                  content: const Text(
                      'Aquí irá la sección de ayuda y preguntas frecuentes.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ),
        ],
      ),
    );
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
            'Tienes: $_cantidadDisponibles disponibles',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: _misBoletos.isEmpty
                ? const Center(
                    child: Text(
                      'No tienes boletos disponibles. ¡Compra uno para empezar!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _misBoletos.length,
                    itemBuilder: (context, index) {
                      final boleto = _misBoletos[index];
                      final isDisponible = boleto.estado == 'Disponible';
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading: Icon(
                            isDisponible ? Icons.local_activity : Icons.history,
                            color: isDisponible ? Colors.green : Colors.grey,
                            size: 30,
                          ),
                          title: Text('Boleto: ${boleto.id}'),
                          subtitle: Text('Estado: ${boleto.estado}'),
                          trailing: isDisponible
                              ? ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      boleto.estado = 'Usado';
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Usar'),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 15),
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
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmacionScreen(
                      cantidadBoletos: _boletosComprar,
                    ),
                  ),
                );
                
                if (result == true) {
                  setState(() {
                    for (int i = 0; i < _boletosComprar; i++) {
                      _misBoletos.add(Boleto(
                        id: 'BOL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}-$i',
                      ));
                    }
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Compra exitosa!')),
                    );
                  }
                }
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
