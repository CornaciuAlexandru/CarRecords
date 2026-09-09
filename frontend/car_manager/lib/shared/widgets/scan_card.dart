import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import 'cm_button.dart';
import '../../core/utils/l10n.dart';

/// Widget reutilizabil pentru scanare documente cu OCR.
/// Pe Windows/desktop: deschide file picker (galerie).
/// Pe Android/iOS: oferă alegere Camera / Galerie.
class ScanCard extends StatelessWidget {
  final File? scannedImage;
  final bool isScanning;
  final Future<void> Function(String filePath) onScan;

  /// Scanari ramase din cele incluse cu masina, si cele cumparate separat.
  /// Se afiseaza INAINTE de a face poza: un om care afla dupa ce a fotografiat
  /// documentul ca nu mai are scanari a pierdut timp degeaba.
  final int? scansLeft;
  final int credits;

  /// Ce se intampla cand nu mai sunt scanari. De obicei deschide oferta.
  final VoidCallback? onNeedMore;

  const ScanCard({
    super.key,
    required this.scannedImage,
    required this.isScanning,
    required this.onScan,
    this.scansLeft,
    this.credits = 0,
    this.onNeedMore,
  });

  /// Cate scanari mai poate face acum, cu tot cu cele cumparate.
  int? get _available =>
      scansLeft == null ? null : scansLeft! + credits;

  bool get _outOfScans => _available != null && _available! <= 0;

  String get _quotaText {
    if (scansLeft == null) return '';
    if (_outOfScans) return 'Ai folosit toate scanarile acestei masini.';
    final included = scansLeft! == 1 ? '1 scanare inclusa' : '${scansLeft!} scanari incluse';
    if (credits <= 0) return 'Iti mai raman $included.';
    final bought = credits == 1 ? '1 cumparata' : '$credits cumparate';
    return 'Iti mai raman $included si $bought.';
  }

  Future<void> _pick(BuildContext context) async {
    final picker = ImagePicker();
    XFile? picked;

    // Pe desktop (Windows) camera nu e disponibila — folosim gallery/file picker
    final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    if (isDesktop) {
      picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    } else {
      // Pe Android/iOS oferim alegere
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tr(context).selectImageSource,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.camera_alt, color: Colors.white)),
                  title: Text(tr(context).photographDocument),
                  subtitle: const Text('Deschide camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.photo_library, color: Colors.white)),
                  title: const Text('Alege din galerie'),
                  subtitle: Text(tr(context).selectExistingPhoto),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        ),
      );
      if (source == null) return;
      picked = await picker.pickImage(source: source, imageQuality: 90);
    }

    if (picked != null) await onScan(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    return Card(
      color: AppColors.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.document_scanner, color: AppColors.primary),
              SizedBox(width: 8),
              Text(tr(context).scanDocument,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ]),
            const SizedBox(height: 6),
            Text(
              isDesktop
                  ? tr(context).scanHintGallery
                  : tr(context).scanHintCamera,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            if (scansLeft != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _outOfScans ? Icons.lock_outline : Icons.auto_awesome_outlined,
                    size: 15,
                    color: _outOfScans ? AppColors.textSecondary : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _quotaText,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _outOfScans
                            ? AppColors.textSecondary
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (scannedImage != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(scannedImage!,
                    height: 120, width: double.infinity, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 10),
            if (_outOfScans)
              // Butonul nu e doar dezactivat: dus in gol, omul n-ar sti ce sa
              // faca mai departe. Il ducem direct la oferta.
              CmButton(
                label: 'Vezi optiunile',
                icon: Icons.shopping_bag_outlined,
                outlined: true,
                onPressed: onNeedMore,
              )
            else
              CmButton(
                label: isScanning
                    ? tr(context).processing
                    : (isDesktop ? tr(context).selectImage : tr(context).cameraOrGallery),
                isLoading: isScanning,
                icon: isDesktop ? Icons.folder_open_outlined : Icons.camera_alt_outlined,
                outlined: true,
                onPressed: isScanning ? null : () => _pick(context),
              ),
          ],
        ),
      ),
    );
  }
}
