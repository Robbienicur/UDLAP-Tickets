import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/boleto.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class HistorialScreen extends StatelessWidget {
  final List<Boleto> boletos;

  const HistorialScreen({super.key, required this.boletos});

  @override
  Widget build(BuildContext context) {
    // Combinamos boletos (compras/usos) con algunas recargas de ejemplo
    final List<_HistorialItem> items = [
      ...boletos.map((b) => _HistorialItem(
            titulo: b.estado == 'Disponible' ? 'Compra de boleto' : 'Boleto usado',
            subtitulo: b.codigoAlfanumerico,
            fecha: b.fechaCompra,
            monto: b.estado == 'Disponible' ? '-\$25.00' : null,
            icon: b.estado == 'Disponible' ? PhosphorIcons.shoppingCart() : PhosphorIcons.checkCircle(),
            color: b.estado == 'Disponible' ? AppColors.primary : AppColors.textMuted,
          )),
      // Mock de recargas para que se vea completo
      _HistorialItem(
        titulo: 'Recarga de saldo',
        subtitulo: 'Caja UDLAP',
        fecha: DateTime.now().subtract(const Duration(days: 1)),
        monto: '+\$100.00',
        icon: PhosphorIcons.wallet(),
        color: AppColors.accentDark,
      ),
    ];

    // Ordenar por fecha (más reciente primero)
    items.sort((a, b) => b.fecha.compareTo(a.fecha));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIcons.arrowLeft()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PhosphorIcon(
                    PhosphorIcons.clockCounterClockwise(),
                    size: 64,
                    color: AppColors.textMuted.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay movimientos aún',
                    style: AppText.body(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final dateStr = DateFormat('dd MMM · HH:mm').format(item.fecha);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: PhosphorIcon(
                          item.icon,
                          color: item.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.titulo,
                              style: AppText.title().copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.subtitulo} · $dateStr',
                              style: AppText.caption(),
                            ),
                          ],
                        ),
                      ),
                      if (item.monto != null)
                        Text(
                          item.monto!,
                          style: AppText.title().copyWith(
                            fontSize: 15,
                            color: item.monto!.startsWith('+') ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _HistorialItem {
  final String titulo;
  final String subtitulo;
  final DateTime fecha;
  final String? monto;
  final IconData icon;
  final Color color;

  _HistorialItem({
    required this.titulo,
    required this.subtitulo,
    required this.fecha,
    this.monto,
    required this.icon,
    required this.color,
  });
}
