import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/documents.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/notifications_provider.dart';

const _typeIcons = {
  'rovinieta_expira': (Icons.card_membership, AppColors.accent),
  'asigurare_expira': (Icons.shield, AppColors.primary),
  'itp_expira':       (Icons.assignment, Colors.teal),
  'revizie_km':       (Icons.speed, AppColors.warning),
  'revizie_data':     (Icons.event, AppColors.warning),
  'sistem':           (Icons.info_outline, Colors.grey),
};

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificări & Alerte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Verifică acum',
            onPressed: () => ref.read(notificationsProvider.notifier).refresh(),
          ),
          TextButton(
            onPressed: () =>
                ref.read(notificationsProvider.notifier).markAllRead(),
            child: const Text('Marchează citite',
                style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              Text('Eroare: $e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(notificationsProvider.notifier).refresh(),
                child: const Text('Reîncearcă'),
              ),
            ],
          ),
        ),
        data: (notifs) {
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Nicio notificare',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Totul este în ordine!',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () =>
                        ref.read(notificationsProvider.notifier).refresh(),
                    icon: const Icon(Icons.search),
                    label: const Text('Verifică documente'),
                  ),
                ],
              ),
            );
          }

          final unread = notifs.where((n) => !n.isRead).length;
          return Column(
            children: [
              if (unread > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  color: AppColors.primary.withOpacity(0.08),
                  child: Row(children: [
                    const Icon(Icons.circle,
                        color: AppColors.primary, size: 10),
                    const SizedBox(width: 8),
                    Text('$unread notificări necitite',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => ref
                          .read(notificationsProvider.notifier)
                          .markAllRead(),
                      child: const Text('Marchează toate',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(notificationsProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: notifs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _NotifCard(
                      notif: notifs[i],
                      onRead: () => ref
                          .read(notificationsProvider.notifier)
                          .markRead(notifs[i].id),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onRead;
  const _NotifCard({required this.notif, required this.onRead});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy HH:mm');
    final (icon, color) =
        _typeIcons[notif.type] ?? (Icons.notifications, Colors.grey);

    return Card(
      color: notif.isRead ? null : color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: notif.isRead
                ? Colors.transparent
                : color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notif.title,
                            style: TextStyle(
                                fontWeight: notif.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                                fontSize: 14)),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notif.message,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(fmt.format(notif.triggeredAt),
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                      if (!notif.isRead)
                        GestureDetector(
                          onTap: onRead,
                          child: const Text('Marchează citit',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
