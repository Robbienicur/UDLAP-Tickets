import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../tickets/confirmacion_screen.dart';
import '../auth/login_screen.dart';

import '../../models/boleto.dart';
import '../../services/api_service.dart';

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
  bool _isLoading = false;
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkSessionAndLoad();
  }

  Future<void> _checkSessionAndLoad() async {
    final hasSession = await _apiService.loadSession();
    if (!hasSession && !widget.esInvitado) {
      // Si no hay sesión y no es invitado, redirigir al login (opcional)
    }
    _loadBoletos();
  }

  Future<void> _loadBoletos() async {
    setState(() {
      _isLoading = true;
    });
    
    final boletos = await _apiService.getBoletos();
    
    // Clasificar y ordenar boletos
    final disponibles = boletos.where((b) => b.estado == 'Disponible').toList();
    final usados = boletos.where((b) => b.estado == 'Usado').toList();
    
    // Los disponibles más nuevos primero
    disponibles.sort((a, b) => b.fechaCompra.compareTo(a.fechaCompra));
    // Los usados después, también por fecha descendente
    usados.sort((a, b) => b.fechaCompra.compareTo(a.fechaCompra));
    
    setState(() {
      _misBoletos.clear();
      _misBoletos.addAll(disponibles);
      _misBoletos.addAll(usados);
      _isLoading = false;
    });
  }

  void _showExpandedQR(Boleto boleto) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Código QR',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                QrImageView(
                  data: boleto.codigoAlfanumerico,
                  version: QrVersions.auto,
                  size: 280.0,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  boleto.codigoAlfanumerico,
                  style: const TextStyle(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Chip(
                  label: Text(boleto.estado),
                  backgroundColor: boleto.estado == 'Disponible' ? Colors.green[100] : Colors.grey[300],
                ),
                if (boleto.estado == 'Disponible') ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final success = await _apiService.consumirBoleto(boleto.codigoAlfanumerico);
                        if (success && context.mounted) {
                          Navigator.of(dialogContext).pop(); // Cerrar diálogo
                          _loadBoletos(); // Recargar lista
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Boleto consumido exitosamente')),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Consumir Boleto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  int get _cantidadDisponibles =>
      _misBoletos.where((b) => b.estado == 'Disponible').length;

  List<Widget> _buildPages() {
    return [
      _buildInicioPage(),
      _buildBoletosPage(),
      _buildPerfilPage(),
    ];
  }

  Widget _buildInicioPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inicio',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // Indicador de Saldo en Inicio
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tu Saldo:', style: TextStyle(fontSize: 16)),
                Text(
                  '\$${_apiService.saldo.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
                    _isLoading = true;
                  });
                  
                  final success = await _apiService.comprarBoletos(_boletosComprar);
                  
                  if (success) {
                    await _loadBoletos();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('¡Compra exitosa!')),
                      );
                    }
                  } else {
                    setState(() {
                      _isLoading = false;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al procesar la compra')),
                      );
                    }
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
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(widget.esInvitado ? 'Invitado' : (_apiService.userEmail?.split('@')[0] ?? 'Estudiante')),
                  subtitle: Text(widget.esInvitado
                      ? 'Sesión de invitado'
                      : (_apiService.userEmail ?? 'Sin correo')),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Saldo Disponible:', style: TextStyle(fontSize: 16)),
                      Text(
                        '\$${_apiService.saldo.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Actividad Reciente',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _misBoletos.isEmpty 
              ? const Center(child: Text('Sin actividad reciente'))
              : ListView.builder(
                  itemCount: _misBoletos.length > 5 ? 5 : _misBoletos.length,
                  itemBuilder: (context, index) {
                    final b = _misBoletos[index];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        b.estado == 'Disponible' ? Icons.add_circle_outline : Icons.check_circle,
                        color: b.estado == 'Disponible' ? Colors.green : Colors.grey,
                      ),
                      title: Text(b.estado == 'Disponible' ? 'Compra de Boleto' : 'Boleto Consumido'),
                      subtitle: Text(DateFormat('dd/MM HH:mm').format(b.fechaCompra)),
                      trailing: Text(b.estado == 'Disponible' ? '-\$25.00' : 'Usado'),
                    );
                  },
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await _apiService.logout();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                }
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Boletos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!_isLoading)
                IconButton(
                  onPressed: _loadBoletos,
                  icon: const Icon(Icons.refresh),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _isLoading
                  ? const SizedBox.shrink()
                  : Text(
                      '$_cantidadDisponibles Disponibles',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
              Text(
                'Saldo: \$${_apiService.saldo.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Cargando boletos...'),
                      ],
                    ),
                  )
                : _misBoletos.isEmpty
                    ? const Center(
                        child: Text(
                          'No tienes boletos disponibles',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _misBoletos.length,
                        itemBuilder: (context, index) {
                          final boleto = _misBoletos[index];
                          final isDisponible = boleto.estado == 'Disponible';
                          final dateStr = DateFormat('dd/MM/yyyy HH:mm')
                              .format(boleto.fechaCompra);

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 4,
                            color: isDisponible ? Colors.white : Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // QR Code
                                  InkWell(
                                    onTap: () => _showExpandedQR(boleto),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      child: QrImageView(
                                        data: boleto.codigoAlfanumerico,
                                        version: QrVersions.auto,
                                        size: 80.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  // Ticket Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Código: ${boleto.codigoAlfanumerico}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Fecha: $dateStr',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDisponible
                                                ? Colors.green[100]
                                                : Colors.grey[400],
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            boleto.estado,
                                            style: TextStyle(
                                              color: isDisponible
                                                  ? Colors.green[800]
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isDisponible)
                                    IconButton(
                                      onPressed: () async {
                                        final success = await _apiService.consumirBoleto(boleto.codigoAlfanumerico);
                                        if (success) {
                                          _loadBoletos();
                                        }
                                      },
                                      icon: const Icon(Icons.check_circle_outline),
                                      color: Colors.blue,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 15),
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
