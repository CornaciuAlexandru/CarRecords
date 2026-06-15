import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import 'cm_button.dart';

/// Widget reutilizabil pentru scanare documente cu OCR.
/// Pe Windows/desktop: deschide file picker (galerie).
/// Pe Android/iOS: oferă alegere Camera / Galerie.
class ScanCard extends StatelessWidget {
  final File? scannedImage;
  final bool isScanning;
  final Future<void> Function(String filePath) onScan;

  const ScanCard({
    super.key,
    required this.scannedImage,
    required this.isScanning,
    required this.onScan,
  });

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
                const Text('Selectează sursa imaginii',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.camera_alt, color: Colors.white)),
                  title: const Text('Fotografiază documentul'),
                  subtitle: const Text('Deschide camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.photo_library, color: Colors.white)),
                  title: const Text('Alege din galerie'),
                  subtitle: const Text('Selectează o fotografie existentă'),
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
            const Row(children: [
              Icon(Icons.document_scanner, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Scanează documentul',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ]),
            const SizedBox(height: 6),
            Text(
              isDesktop
                  ? 'Selectați o imagine a documentului pentru completare automată a câmpurilor.'
                  : 'Fotografiați sau selectați documentul pentru completare automată.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            if (scannedImage != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(scannedImage!,
                    height: 120, width: double.infinity, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 10),
            CmButton(
              label: isScanning
                  ? 'Se procesează...'
                  : (isDesktop ? 'Selectează imagine' : 'Fotografiază / Galerie'),
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
