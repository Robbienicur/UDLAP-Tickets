import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../tickets/confirmacion_screen.dart';
import '../auth/login_screen.dart';
import '../../theme/app_theme.dart';

import '../../models/boleto.dart';
import '../../services/api_service.dart';

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

  Future<void> _confirmarCompra() async {
    HapticFeedback.lightImpact();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ConfirmacionScreen(cantidadBoletos: _boletosComprar),
      ),
    );

    if (!mounted) return;
    if (result == true) {
      setState(() {
        _isLoading = true;
      });
      
      final success = await _apiService.comprarBoletos(_boletosComprar);
      
      if (success) {
        await _loadBoletos();
        if (mounted) {
          HapticFeedback.mediumImpact();
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
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _InicioPage(
        cantidad: _boletosComprar,
        precioBoleto: _precioBoleto,
        boletosDisponibles: _cantidadDisponibles,
        saldo: _apiService.saldo,
        onIncrement: () {
          HapticFeedback.selectionClick();
          setState(() => _boletosComprar++);
        },
        onDecrement: () {
          if (_boletosComprar > 1) {
            HapticFeedback.selectionClick();
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
        onMarcarUsado: (boleto) async {
          HapticFeedback.lightImpact();
          final success = await _apiService.consumirBoleto(boleto.codigoAlfanumerico);
          if (success && mounted) {
            _loadBoletos();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Boleto consumido exitosamente')),
            );
          }
        },
        onComprarPrimero: () => setState(() => _selectedIndex = 0),
      ),
      _PerfilPage(esInvitado: widget.esInvitado),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          HapticFeedback.selectionClick();
          setState(() => _selectedIndex = index);
        },
        items: [
          BottomNavigationBarItem(
            icon: PhosphorIcon(PhosphorIcons.house()),
            activeIcon: PhosphorIcon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: PhosphorIcon(PhosphorIcons.ticket()),
            activeIcon:
                PhosphorIcon(PhosphorIcons.ticket(PhosphorIconsStyle.fill)),
            label: 'Mis boletos',
          ),
          BottomNavigationBarItem(
            icon: PhosphorIcon(PhosphorIcons.user()),
            activeIcon:
                PhosphorIcon(PhosphorIcons.user(PhosphorIconsStyle.fill)),
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
  final double saldo;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onComprar;
  final VoidCallback onIrAMisBoletos;

  const _InicioPage({
    required this.cantidad,
    required this.precioBoleto,
    required this.boletosDisponibles,
    required this.saldo,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UDLAP Tickets',
                      style: AppText.h3(color: AppColors.primary),
                    ),
                    Text(
                      'Hola, bienvenido',
                      style: AppText.caption(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ResumenCard(
            disponibles: boletosDisponibles,
            saldo: saldo,
            onVerBoletos: onIrAMisBoletos,
          ),
          const SizedBox(height: 24),
          Text('Comprar boletos', style: AppText.h2()),
          const SizedBox(height: 6),
          Text(
            '\$${precioBoleto.toStringAsFixed(0)} MXN por boleto',
            style: AppText.body(color: AppColors.textSecondary),
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
                Text('Cantidad', style: AppText.label()),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CounterButton(
                      icon: PhosphorIcons.minus(PhosphorIconsStyle.bold),
                      onPressed: cantidad > 1 ? onDecrement : null,
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        '$cantidad',
                        textAlign: TextAlign.center,
                        style: AppText.priceLarge(color: AppColors.primary),
                      ),
                    ),
                    _CounterButton(
                      icon: PhosphorIcons.plus(PhosphorIconsStyle.bold),
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
                    Text('Total', style: AppText.label()),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: AppText.priceMedium(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: onComprar,
                    icon: PhosphorIcon(
                      PhosphorIcons.shoppingCart(PhosphorIconsStyle.bold),
                      size: 18,
                    ),
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
          child: PhosphorIcon(
            icon,
            color: enabled ? AppColors.primary : AppColors.textMuted,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final int disponibles;
  final double saldo;
  final VoidCallback onVerBoletos;

  const _ResumenCard({
    required this.disponibles,
    required this.saldo,
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: PhosphorIcon(
                  PhosphorIcons.ticket(PhosphorIconsStyle.fill),
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
                      style: AppText.h2(color: Colors.white),
                    ),
                    Text(
                      disponibles == 0
                          ? 'No tienes boletos disponibles'
                          : 'Disponibles para usar',
                      style: AppText.caption(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onVerBoletos,
                icon: PhosphorIcon(
                  PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                  color: Colors.white,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo disponible',
                style: AppText.caption(color: Colors.white70),
              ),
              Text(
                '\$${saldo.toStringAsFixed(2)}',
                style: AppText.title(color: Colors.white),
              ),
            ],
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
              Expanded(child: Text('Mis boletos', style: AppText.h1())),
              if (!isLoading)
                IconButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onRefresh();
                  },
                  icon: PhosphorIcon(
                    PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.bold),
                  ),
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
              style: AppText.body(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 18),
          Expanded(
            child: isLoading
                ? const _BoletosSkeleton()
                : boletos.isEmpty
                    ? _EmptyState(onComprar: onComprarPrimero)
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: boletos.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return _PerforatedTicket(
                            boleto: boletos[index],
                            onMarcarUsado: () => onMarcarUsado(boletos[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _BoletosSkeleton extends StatelessWidget {
  const _BoletosSkeleton();



  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, _) {
        return Shimmer.fromColors(
          baseColor: AppColors.surfaceVariant,
          highlightColor: AppColors.surface,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
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
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: PhosphorIcon(
              PhosphorIcons.ticket(),
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text('No tienes boletos', style: AppText.h3()),
          const SizedBox(height: 6),
          Text(
            'Compra tu primer boleto para empezar',
            style: AppText.body(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              onComprar();
            },
            icon: PhosphorIcon(
              PhosphorIcons.plus(PhosphorIconsStyle.bold),
              size: 16,
            ),
            label: const Text('Comprar boletos'),
          ),
        ],
      ),
    );
  }
}

class _PerforatedTicket extends StatelessWidget {
  final Boleto boleto;
  final VoidCallback onMarcarUsado;

  const _PerforatedTicket({
    required this.boleto,
    required this.onMarcarUsado,
  });

  @override
  Widget build(BuildContext context) {
    final isDisponible = boleto.estado == 'Disponible';
    final dateStr =
        DateFormat('dd/MM/yyyy · HH:mm').format(boleto.fechaCompra);

    return ClipPath(
      clipper: _TicketClipper(notchRadius: 12, notchOffset: 110),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 110,
                color: AppColors.primaryContainer,
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: QrImageView(
                        data: boleto.codigoAlfanumerico,
                        version: QrVersions.auto,
                        size: 72,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'BOLETO',
                      style: AppText.caption(color: AppColors.primary)
                          .copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              CustomPaint(
                size: const Size(2, double.infinity),
                painter: _DashedLinePainter(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        boleto.codigoAlfanumerico,
                        style: AppText.mono(size: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.calendar(),
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              dateStr,
                              style: AppText.caption(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _EstadoChip(
                            estado: boleto.estado,
                            isDisponible: isDisponible,
                          ),
                          const Spacer(),
                          if (isDisponible)
                            IconButton(
                              onPressed: onMarcarUsado,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: PhosphorIcon(
                                PhosphorIcons.checkCircle(
                                  PhosphorIconsStyle.fill,
                                ),
                                color: AppColors.primary,
                                size: 24,
                              ),
                              tooltip: 'Marcar como usado',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  final double notchRadius;
  final double notchOffset;

  _TicketClipper({required this.notchRadius, required this.notchOffset});

  @override
  Path getClip(Size size) {
    final path = Path();
    const r = 16.0;
    final cx = notchOffset;
    final cyTop = 0.0;
    final cyBottom = size.height;

    path.moveTo(r, 0);
    path.lineTo(cx - notchRadius, 0);
    path.arcToPoint(
      Offset(cx + notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(size.width - r, 0);
    path.arcToPoint(
      Offset(size.width, r),
      radius: const Radius.circular(r),
    );
    path.lineTo(size.width, size.height - r);
    path.arcToPoint(
      Offset(size.width - r, size.height),
      radius: const Radius.circular(r),
    );
    path.lineTo(cx + notchRadius, size.height);
    path.arcToPoint(
      Offset(cx - notchRadius, size.height),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(r, size.height);
    path.arcToPoint(
      Offset(0, size.height - r),
      radius: const Radius.circular(r),
    );
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: const Radius.circular(r));
    path.close();

    // suppress unused-field warning when zero
    if (cyTop > 0 || cyBottom < 0) path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1.5;
    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double y = 14;
    while (y < size.height - 14) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashHeight), paint);
      y += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            estado,
            style: AppText.caption(color: fg).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11,
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
          Text('Mi perfil', style: AppText.h1()),
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
                  child: PhosphorIcon(
                    PhosphorIcons.user(PhosphorIconsStyle.fill),
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        esInvitado ? 'Invitado' : 'Estudiante UDLAP',
                        style: AppText.title(),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        esInvitado ? 'Sesión de invitado' : 'correo@udlap.mx',
                        style: AppText.caption(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _PerfilTile(
            icon: PhosphorIcons.fileText(),
            title: 'Términos y condiciones',
            onTap: () => _mostrarDialogo(
              context,
              'Términos y Condiciones',
              'Aquí irán los términos y condiciones de uso de la aplicación.',
            ),
          ),
          const SizedBox(height: 8),
          _PerfilTile(
            icon: PhosphorIcons.question(),
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
                HapticFeedback.mediumImpact();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              icon: PhosphorIcon(
                PhosphorIcons.signOut(PhosphorIconsStyle.bold),
                size: 18,
              ),
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
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
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
                child: PhosphorIcon(
                  icon,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: AppText.title())),
              PhosphorIcon(
                PhosphorIcons.caretRight(),
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
