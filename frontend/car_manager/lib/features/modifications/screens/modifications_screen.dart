import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/models/documents.dart';
import '../../../core/services/car_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/l10n.dart';
import '../../../core/widgets/ad_banner.dart';

final modificationsFutureProvider =
    FutureProvider.family<List<CarModification>, String>(
        (ref, carId) => CarService().getModifications(carId));

/// Eticheta tradusa pentru categoria modificarii.
String _categoryLabel(BuildContext context, String cat) => {
  'motor':      tr(context).catEngine,
  'exterior':   tr(context).catExterior,
  'interior':   tr(context).catInterior,
  'suspensie':  tr(context).catSuspension,
  'audio':      tr(context).catAudio,
  'electronic': tr(context).catElectronic,
  'frane':      tr(context).catBrakes,
  'altul':      tr(context).other,
}[cat] ?? cat;
const _categoryColors = {
  'motor': Colors.red, 'exterior': Colors.blue, 'interior': Colors.teal,
  'suspensie': Colors.orange, 'audio': Colors.purple, 'electronic': Colors.cyan,
  'frane': Colors.deepOrange, 'altul': Colors.grey,
};

class ModificationsScreen extends ConsumerWidget {
  final String carId;
  const ModificationsScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(modificationsFutureProvider(carId));
    return Scaffold(
      bottomNavigationBar: const AdBanner(),
      appBar: AppBar(title: Text(tr(context).modifications)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/cars/$carId/modifications/add'),
        icon: const Icon(Icons.add), label: Text(tr(context).add),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(tr(context).errorWith('$e'))),
        data: (mods) => mods.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.tune_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(tr(context).noModifications, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.push('/cars/$carId/modifications/add'),
                  icon: const Icon(Icons.add), label: Text(tr(context).addModification),
                ),
              ]))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: mods.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _ModCard(
                  mod: mods[i], carId: carId,
                  onChanged: () => ref.invalidate(modificationsFutureProvider(carId)),
                ),
              ),
      ),
    );
  }
}

class _ModCard extends StatefulWidget {
  final CarModification mod;
  final String carId;
  final VoidCallback onChanged;
  const _ModCard({required this.mod, required this.carId, required this.onChanged});

  @override
  State<_ModCard> createState() => _ModCardState();
}

class _ModCardState extends State<_ModCard> {
  bool _uploadingPhoto = false;
  late List<String> _photos;

  @override
  void initState() {
    super.initState();
    _photos = List<String>.from(
        (widget.mod.photos ?? []).map((p) => p.toString()));
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr(context).deleteModification),
        content: Text(tr(context).deleteConfirmGeneric(widget.mod.description)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(tr(context).cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: Text(tr(context).delete)),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await CarService().deleteModification(widget.carId, widget.mod.id);
      widget.onChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(tr(context).errorWith('$e')),
              backgroundColor: AppColors.danger),
        );
      }
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      final url = await CarService().uploadModificationPhoto(
          widget.carId, widget.mod.id, picked.path);
      setState(() => _photos.add(url));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(tr(context).uploadError('$e')),
              backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  void _viewPhoto(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PhotoViewer(photos: _photos, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy');
    final color =
        (_categoryColors[widget.mod.category] ?? Colors.grey) as Color;
    final label =
        _categoryLabel(context, widget.mod.category);
    final baseHost = backendBaseUrl.replaceFirst('/api/v1', '');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Header: categorie + butoane ──
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Text(label,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
            Row(children: [
              if (widget.mod.isHomologated)
                Row(children: [
                  Icon(Icons.verified, color: AppColors.success, size: 16),
                  SizedBox(width: 4),
                  Text(tr(context).homologatedShort,
                      style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  SizedBox(width: 4),
                ]),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') {
                    context.push(
                        '/cars/${widget.carId}/modifications/add',
                        extra: widget.mod);
                  }
                  if (v == 'delete') _delete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                          leading: Icon(Icons.edit_outlined,
                              color: AppColors.primary),
                          title: Text(tr(context).edit),
                          dense: true)),
                  PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                          leading: Icon(Icons.delete_outline,
                              color: AppColors.danger),
                          title: Text(tr(context).delete,
                              style: TextStyle(color: AppColors.danger)),
                          dense: true)),
                ],
              ),
            ]),
          ]),
          const SizedBox(height: 10),

          // ── Descriere ──
          Text(widget.mod.description,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          if (widget.mod.modificationDate != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.calendar_today,
                  size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(fmt.format(widget.mod.modificationDate!),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ]),
          ],
          if (widget.mod.performedBy != null ||
              widget.mod.cost != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              if (widget.mod.performedBy != null) ...[
                const Icon(Icons.build_outlined,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(widget.mod.performedBy!,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(width: 16),
              ],
              if (widget.mod.cost != null) ...[
                const Icon(Icons.payments_outlined,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                    '${widget.mod.cost!.toStringAsFixed(0)} ${widget.mod.currency}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: 13)),
              ],
            ]),
          ],

          // ── Sectiune poze ──
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _photos.isEmpty
                    ? tr(context).noPhotos
                    : '${_photos.length} ${_photos.length == 1 ? 'poză' : 'poze'}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              GestureDetector(
                onTap: _uploadingPhoto ? null : _pickAndUploadPhoto,
                child: _uploadingPhoto
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 16, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(tr(context).addPhoto,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ],
          ),
          if (_photos.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final url = '$baseHost/photos${_photos[i]}';
                  return GestureDetector(
                    onTap: () => _viewPhoto(i),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: AppColors.border,
                          child: const Icon(Icons.broken_image_outlined,
                              color: AppColors.textSecondary),
                        ),
                        loadingBuilder: (_, child, progress) =>
                            progress == null
                                ? child
                                : Container(
                                    width: 80,
                                    height: 80,
                                    color: AppColors.border,
                                    child: const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Vizualizator poze fullscreen ───────────────────────────────────────────

class _PhotoViewer extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  const _PhotoViewer(
      {required this.photos, required this.initialIndex});

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late int _current;
  late PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseHost = backendBaseUrl.replaceFirst('/api/v1', '');
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
            'Poza ${_current + 1} / ${widget.photos.length}',
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ),
      body: PageView.builder(
        controller: _pageCtrl,
        itemCount: widget.photos.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) {
          final url = '$baseHost/photos${widget.photos[i]}';
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 64),
              ),
            ),
          );
        },
      ),
    );
  }
}
