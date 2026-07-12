import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../api/api_client.dart';
import '../theme/app_theme.dart';

const _appVersion = '1.0.12';   // ← actualizat la fiecare release

class UpdateInfo {
  final String serverVersion;
  final bool updateAvailable;
  final bool forceUpdate;
  final String changelog;
  final String? downloadUrl;
  final String? installerFilename;
  final String? sha256;

  const UpdateInfo({
    required this.serverVersion,
    required this.updateAvailable,
    required this.forceUpdate,
    required this.changelog,
    this.downloadUrl,
    this.installerFilename,
    this.sha256,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> j) => UpdateInfo(
    serverVersion:    j['version'] ?? _appVersion,
    updateAvailable:  j['update_available'] ?? false,
    forceUpdate:      j['force_update'] ?? false,
    changelog:        j['changelog'] ?? '',
    downloadUrl:      j['download_url'],
    installerFilename: j['installer_filename'],
    sha256:           j['sha256'],
  );
}

class UpdateService {
  final Dio _dio = createDio();

  /// Verifica daca exista o versiune noua.
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final baseHost = backendBaseUrl.replaceFirst('/api/v1', '');
      final resp = await Dio(BaseOptions(
        baseUrl: baseHost,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      )).get(
        '/version',
        queryParameters: {'client_version': _appVersion},
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return UpdateInfo.fromJson(resp.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Descarca installer-ul si il ruleaza. Doar pe Windows.
  Future<void> downloadAndInstall(
    UpdateInfo info,
    BuildContext context, {
    required VoidCallback onProgress,
  }) async {
    if (!Platform.isWindows || info.downloadUrl == null) return;

    final tmpDir   = await getTemporaryDirectory();
    final savePath = '${tmpDir.path}\\${info.installerFilename ?? "CarRecords_Setup.exe"}';
    final baseHost = backendBaseUrl.replaceFirst('/api/v1', '');
    final fullUrl  = '$baseHost${info.downloadUrl}';

    // Dialog progres descarcare
    double progress = 0;
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(
          builder: (ctx, setS) => AlertDialog(
            title: const Row(children: [
              Icon(Icons.download_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Se descarcă update-ul'),
            ]),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Versiunea ${info.serverVersion}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ]),
          ),
        ),
      );
    }

    try {
      await _dio.download(
        fullUrl,
        savePath,
        onReceiveProgress: (rec, total) {
          if (total > 0) {
            progress = rec / total;
            onProgress();
          }
        },
        options: Options(receiveTimeout: const Duration(minutes: 10)),
      );
    } catch (_) {
      // Download esuat — inchidem dialogul si anuntam utilizatorul
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showError(context, 'Descărcarea a eșuat. Verifică conexiunea și încearcă din nou.');
      }
      return;
    }

    // ── Verificare integritate SHA-256 ─────────────────────────────
    // Blocheaza executia daca fisierul descarcat difera de cel publicat
    // (download corupt sau atac man-in-the-middle).
    if (info.sha256 != null && info.sha256!.isNotEmpty) {
      final actual = sha256.convert(await File(savePath).readAsBytes()).toString();
      if (actual.toLowerCase() != info.sha256!.toLowerCase()) {
        try { File(savePath).deleteSync(); } catch (_) {}
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          _showError(context,
              'Verificarea integrității a eșuat — fișierul descărcat este corupt sau modificat. Instalarea a fost anulată.');
        }
        return;
      }
    }

    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

    // Ruleaza installer-ul (se instaleaza pe deasupra, silentios)
    await Process.start(savePath, ['/SILENT', '/CLOSEAPPLICATIONS'],
        runInShell: false);
    // Inchide app-ul curent — installer-ul va redeschide versiunea noua
    exit(0);
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.error_outline, color: AppColors.danger),
          SizedBox(width: 8),
          Text('Eroare la actualizare'),
        ]),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Arata dialog de update. Returneaza true daca user-ul a acceptat.
Future<bool?> showUpdateDialog(BuildContext context, UpdateInfo info) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: !info.forceUpdate,
    builder: (_) => AlertDialog(
      title: Row(children: [
        const Icon(Icons.system_update_alt, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(info.forceUpdate ? 'Update obligatoriu' : 'Update disponibil'),
      ]),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(text: TextSpan(
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            children: [
              const TextSpan(text: 'Versiune nouă: '),
              TextSpan(text: info.serverVersion,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          )),
          if (info.changelog.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Noutăți:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(info.changelog,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
          if (info.forceUpdate) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.4)),
              ),
              child: const Row(children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Această versiune nu mai este suportată. Actualizarea este obligatorie.',
                      style: TextStyle(fontSize: 12, color: AppColors.warning)),
                ),
              ]),
            ),
          ],
        ],
      ),
      actions: [
        if (!info.forceUpdate)
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Mai târziu'),
          ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Actualizează acum'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}
