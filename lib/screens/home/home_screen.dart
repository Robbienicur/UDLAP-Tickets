import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../tickets/confirmacion_screen.dart';
import '../auth/login_screen.dart';
// REMOVIBLE-PRUEBA: import de la pantalla de anuncios demo
import '../ads/anuncios_screen.dart';
import '../../theme/app_theme.dart';

class Boleto {
  final String id;
  final String codigoAlfanumerico;
  final DateTime fechaCompra;
  String estado;

  Boleto({
    required this.id,
    required this.codigoAlfanumerico,
    required this.fechaCompra,
    this.estado = 'Disponible',
  });
}

class HomeScreen extends StatefulWidget {
  final bool esInvitado;

  const HomeScreen({super.key, this.esInvitado = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _precioBoleto = 25.0;

  int _selectedIndex = 0;
  final List<Boleto> _misBoletos = [];
  int _boletosComprar = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBoletos();
  }

  Future<void> _loadBoletos() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isLoading = false);
  }

  int get _cantidadDisponibles =>
      _misBoletos.where((b) => b.estado == 'Disponible').length;

  Future<void> _confirmarCompra() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmacionScreen(
          cantidadBoletos: _boletosComprar,
        ),
      ),
    );

    if (!mounted) return;
    if (result == true) {
      setState(() {
        for (int i = 0; i < _boletosComprar; i++) {
          final now = DateTime.now();
          final id =
              'BOL-${now.millisecondsSinceEpoch.toString().substring(7)}-$i';
          _misBoletos.insert(
            0,
            Boleto(
              id: id,
              codigoAlfanumerico: id,
              fechaCompra: now,
            ),
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Compra exitosa!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _InicioPage(
        cantidad: _boletosComprar,
        precioBoleto: _precioBoleto,
        boletosDisponibles: _cantidadDisponibles,
        onIncrement: () => setState(() => _boletosComprar++),
        onDecrement: () {
          if (_boletosComprar > 1) {
            setState(() => _boletosComprar--);
          }
        },
        onComprar: _confirmarCompra,
        onIrAMisBoletos: () => setState(() => _selectedIndex = 1),
      ),
      _MisBoletosPage(
        boletos: _misBoletos,
        isLoading: _isLoading,
        onRefresh: _loadBoletos,
        onMarcarUsado: (boleto) {
          setState(() {
            boleto.estado = 'Usado';
          });
        },
        onComprarPrimero: () => setState(() => _selectedIndex = 0),
      ),
      // REMOVIBLE-PRUEBA: tab de Anuncios (sección demo de AdMob)
      const AnunciosScreen(),
      _PerfilPage(esInvitado: widget.esInvitado),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number_rounded),
            label: 'Mis boletos',
          ),
          // REMOVIBLE-PRUEBA: item del bottom nav para Anuncios
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign_rounded),
            label: 'Anuncios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Mi perfil',
          ),
        ],
      ),
    );
  }
}

class _InicioPage extends StatelessWidget {
  final int cantidad;
  final double precioBoleto;
  final int boletosDisponibles;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onComprar;
  final VoidCallback onIrAMisBoletos;

  const _InicioPage({
    required this.cantidad,
    required this.precioBoleto,
    required this.boletosDisponibles,
    required this.onIncrement,
    required this.onDecrement,
    required this.onComprar,
    required this.onIrAMisBoletos,
  });

  @override
  Widget build(BuildContext context) {
    final total = cantidad * precioBoleto;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/udlap-tickets-logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UDLAP Tickets',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Hola, bienvenido',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ResumenCard(
            disponibles: boletosDisponibles,
            onVerBoletos: onIrAMisBoletos,
          ),
          const SizedBox(height: 24),
          const Text(
            'Comprar boletos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\$${precioBoleto.toStringAsFixed(0)} MXN por boleto',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                const Text(
                  'Cantidad',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CounterButton(
                      icon: Icons.remove,
                      onPressed: cantidad > 1 ? onDecrement : null,
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        '$cantidad',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    _CounterButton(
                      icon: Icons.add,
                      onPressed: onIncrement,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: onComprar,
                    icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                    label: const Text('Comprar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CounterButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: enabled ? AppColors.primaryContainer : AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: enabled ? AppColors.primary : AppColors.textMuted,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final int disponibles;
  final VoidCallback onVerBoletos;

  const _ResumenCard({
    required this.disponibles,
    required this.onVerBoletos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.confirmation_number_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$disponibles ${disponibles == 1 ? "boleto" : "boletos"}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  disponibles == 0
                      ? 'No tienes boletos disponibles'
                      : 'Disponibles para usar',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onVerBoletos,
            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _MisBoletosPage extends StatelessWidget {
  final List<Boleto> boletos;
  final bool isLoading;
  final VoidCallback onRefresh;
  final ValueChanged<Boleto> onMarcarUsado;
  final VoidCallback onComprarPrimero;

  const _MisBoletosPage({
    required this.boletos,
    required this.isLoading,
    required this.onRefresh,
    required this.onMarcarUsado,
    required this.onComprarPrimero,
  });

  @override
  Widget build(BuildContext context) {
    final disponibles = boletos.where((b) => b.estado == 'Disponible').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Mis boletos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (!isLoading)
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  color: AppColors.primary,
                ),
            ],
          ),
          if (!isLoading) ...[
            const SizedBox(height: 4),
            Text(
              disponibles == 0
                  ? 'Sin boletos disponibles'
                  : 'Tienes $disponibles ${disponibles == 1 ? "boleto disponible" : "boletos disponibles"}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 14),
                        Text(
                          'Cargando boletos…',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : boletos.isEmpty
                    ? _EmptyState(onComprar: onComprarPrimero)
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: boletos.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _BoletoCard(
                            boleto: boletos[index],
                            onMarcarUsado: () =>
                                onMarcarUsado(boletos[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onComprar;

  const _EmptyState({required this.onComprar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No tienes boletos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Compra tu primer boleto para empezar',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onComprar,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Comprar boletos'),
          ),
        ],
      ),
    );
  }
}

class _BoletoCard extends StatelessWidget {
  final Boleto boleto;
  final VoidCallback onMarcarUsado;

  const _BoletoCard({required this.boleto, required this.onMarcarUsado});

  @override
  Widget build(BuildContext context) {
    final isDisponible = boleto.estado == 'Disponible';
    final dateStr =
        DateFormat('dd/MM/yyyy · HH:mm').format(boleto.fechaCompra);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: QrImageView(
                data: boleto.codigoAlfanumerico,
                version: QrVersions.auto,
                size: 76,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    boleto.codigoAlfanumerico,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _EstadoChip(
                    estado: boleto.estado,
                    isDisponible: isDisponible,
                  ),
                ],
              ),
            ),
            if (isDisponible)
              IconButton(
                onPressed: onMarcarUsado,
                icon: const Icon(Icons.check_circle_outline),
                color: AppColors.primary,
                tooltip: 'Marcar como usado',
              ),
          ],
        ),
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final String estado;
  final bool isDisponible;

  const _EstadoChip({required this.estado, required this.isDisponible});

  @override
  Widget build(BuildContext context) {
    final bg = isDisponible
        ? AppColors.primaryContainer
        : AppColors.surfaceVariant;
    final fg = isDisponible ? AppColors.primary : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            estado,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerfilPage extends StatelessWidget {
  final bool esInvitado;

  const _PerfilPage({required this.esInvitado});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Mi perfil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        esInvitado ? 'Invitado' : 'Estudiante UDLAP',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        esInvitado ? 'Sesión de invitado' : 'correo@udlap.mx',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _PerfilTile(
            icon: Icons.description_outlined,
            title: 'Términos y condiciones',
            onTap: () => _mostrarDialogo(
              context,
              'Términos y Condiciones',
              'Aquí irán los términos y condiciones de uso de la aplicación.',
            ),
          ),
          const SizedBox(height: 8),
          _PerfilTile(
            icon: Icons.help_outline,
            title: 'Ayuda',
            onTap: () => _mostrarDialogo(
              context,
              'Ayuda',
              'Aquí irá la sección de ayuda y preguntas frecuentes.',
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogo(BuildContext context, String titulo, String contenido) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(contenido),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _PerfilTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _PerfilTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
