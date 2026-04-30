import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/app_theme.dart';

class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos estáticos de ejemplo para las notificaciones
    final notificaciones = [
      {
        'titulo': '¡Bienvenido a UDLAP Tickets!',
        'mensaje': 'Gracias por unirte. Aquí podrás gestionar todos tus boletos de estacionamiento.',
        'fecha': 'Hace 2 min',
        'leida': false,
      },
      {
        'titulo': 'Boleto consumido',
        'mensaje': 'Tu boleto AB1234 fue validado correctamente en la salida principal.',
        'fecha': 'Ayer, 18:45',
        'leida': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIcons.arrowLeft()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: notificaciones.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PhosphorIcon(
                    PhosphorIcons.bellSlash(),
                    size: 64,
                    color: AppColors.textMuted.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes notificaciones',
                    style: AppText.body(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notificaciones.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = notificaciones[index];
                final bool leida = notification['leida'] as bool;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: leida ? AppColors.surface : AppColors.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: leida ? AppColors.divider : AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: leida ? AppColors.surfaceVariant : AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: PhosphorIcon(
                          leida ? PhosphorIcons.bell() : PhosphorIcons.bellRinging(PhosphorIconsStyle.fill),
                          color: leida ? AppColors.textMuted : AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification['titulo'] as String,
                              style: AppText.title().copyWith(
                                fontSize: 15,
                                fontWeight: leida ? FontWeight.w600 : FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification['mensaje'] as String,
                              style: AppText.caption().copyWith(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notification['fecha'] as String,
                              style: AppText.caption().copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (!leida)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
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
