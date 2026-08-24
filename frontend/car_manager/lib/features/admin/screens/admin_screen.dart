import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';
import '../../../core/utils/l10n.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context).administration),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: tr(context).reload,
            onPressed: () {
              ref.invalidate(adminStatsProvider);
              ref.read(adminUsersProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminStatsProvider);
          await ref.read(adminUsersProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Stats ──────────────────────────────────────────
            statsAsync.when(
              loading: () => const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox(),
              data: (stats) => _StatsRow(stats: stats),
            ),
            const SizedBox(height: 20),

            // ── Titlu lista ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr(context).users,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                usersAsync.whenOrNull(
                  data: (users) => Text(
                    '${users.length} conturi',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ) ?? const SizedBox(),
              ],
            ),
            const SizedBox(height: 10),

            // ── Lista utilizatori ──────────────────────────────
            usersAsync.when(
              loading: () => const Center(
                  child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              )),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.danger),
                      const SizedBox(height: 12),
                      Text(tr(context).errorWith('$e'), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(adminUsersProvider.notifier).refresh(),
                        child: Text(tr(context).retry),
                      ),
                    ],
                  ),
                ),
              ),
              data: (users) => Column(
                children: users
                    .map((u) => _UserCard(
                          user: u,
                          onEdit: () => _showEditDialog(context, ref, u),
                          onDelete: () =>
                              _confirmDelete(context, ref, u),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, AdminUserInfo user) {
    showDialog(
      context: context,
      builder: (_) => _EditUserDialog(user: user, ref: ref),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, AdminUserInfo user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr(context).deleteUser),
        content: Text(
            'Ești sigur că vrei să ștergi contul lui "${user.fullName}"?\n\nToate mașinile și documentele asociate vor fi șterse permanent.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr(context).cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(adminUsersProvider.notifier)
                    .deleteUser(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          tr(context).userDeleted(user.fullName)),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  final msg = e is DioException
                      ? (e.response?.data?['detail'] ?? tr(context).error)
                      : e.toString();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Eroare: $msg'),
                        backgroundColor: AppColors.danger),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(tr(context).delete),
          ),
        ],
      ),
    );
  }
}

// ── Stats row ──────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _StatCard(
                label: tr(context).users,
                value: '${stats['total_users'] ?? 0}',
                icon: Icons.people_outline,
                color: AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
                label: tr(context).navCars,
                value: '${stats['total_cars'] ?? 0}',
                icon: Icons.directions_car_outlined,
                color: AppColors.success)),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
                label: tr(context).insurance,
                value: '${stats['total_insurance_policies'] ?? 0}',
                icon: Icons.security_outlined,
                color: AppColors.warning)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── User card ──────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final AdminUserInfo user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _UserCard(
      {required this.user, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == 'admin';
    final createdStr = user.createdAt != null
        ? '${user.createdAt!.day.toString().padLeft(2, '0')}.'
            '${user.createdAt!.month.toString().padLeft(2, '0')}.'
            '${user.createdAt!.year}'
        : '—';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Linie 1: avatar + nume + badge-uri ──
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      isAdmin ? AppColors.warning : AppColors.primary,
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.fullName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Badge rol
                          _Badge(
                            label: isAdmin ? 'Admin' : 'User',
                            color: isAdmin
                                ? AppColors.warning
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          // Badge status
                          if (!user.isActive)
                            _Badge(
                                label: tr(context).inactive,
                                color: AppColors.danger),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(user.email,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ── Linie 2: statistici ──
            Row(
              children: [
                _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: 'Creat: $createdStr'),
                const SizedBox(width: 8),
                _InfoChip(
                    icon: Icons.directions_car_outlined,
                    label: tr(context).carsCount(user.carCount, user.maxCars)),
                const SizedBox(width: 8),
                _InfoChip(
                    icon: Icons.description_outlined,
                    label: '${user.recordsCount} doc.'),
              ],
            ),
            const SizedBox(height: 10),

            // ── Linie 3: butoane ──
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(tr(context).edit),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                if (!isAdmin)
                  OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: Text(tr(context).delete),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Edit dialog ────────────────────────────────────────────────────────────

class _EditUserDialog extends StatefulWidget {
  final AdminUserInfo user;
  final WidgetRef ref;
  const _EditUserDialog({required this.user, required this.ref});

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  late bool _isActive;
  late String _role;
  late String _subscriptionTier;
  late int _maxCars;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _isActive = widget.user.isActive;
    _role = widget.user.role;
    _subscriptionTier = widget.user.subscriptionTier;
    _maxCars = widget.user.maxCars;
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await widget.ref.read(adminUsersProvider.notifier).updateUser(
        widget.user.id,
        {
          'is_active': _isActive,
          'role': _role,
          'subscription_tier': _subscriptionTier,
          'max_cars': _maxCars,
        },
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(tr(context).userUpdated),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e is DioException
            ? (e.response?.data?['detail'] ?? tr(context).error)
            : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Eroare: $msg'),
              backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.manage_accounts, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.user.fullName,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.user.email,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),

            // Cont activ
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr(context).accountActive),
              subtitle: Text(tr(context).accountActiveHint,
                  style: TextStyle(fontSize: 12)),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
              activeColor: AppColors.primary,
            ),
            const Divider(),

            // Rol
            Text(tr(context).role,
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'user', label: Text('User')),
                ButtonSegment(value: 'admin', label: Text('Admin')),
              ],
              selected: {_role},
              onSelectionChanged: (s) => setState(() => _role = s.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primary;
                  }
                  return null;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return null;
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Abonament
            Text(tr(context).subscription,
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'free', label: Text('Free')),
                ButtonSegment(value: 'premium', label: Text('Premium')),
              ],
              selected: {_subscriptionTier},
              onSelectionChanged: (s) =>
                  setState(() => _subscriptionTier = s.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primary;
                  }
                  return null;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return null;
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Limita masini
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr(context).carLimit,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.danger,
                      onPressed: _maxCars > 1
                          ? () => setState(() => _maxCars--)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('$_maxCars',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.primary)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                      onPressed: _maxCars < 999
                          ? () => setState(() => _maxCars++)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text(tr(context).cancel),
        ),
        ElevatedButton.icon(
          onPressed: _loading ? null : _save,
          icon: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.save_outlined, size: 18),
          label: Text(tr(context).save),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ── Widgets helper ─────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
