import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../theme/app_theme.dart';
import '../services/update_service.dart';
import '../services/server_discovery.dart';

/// Wrapper afisat la pornire — descopera backend-ul si verifica disponibilitatea.
class StartupWrapper extends StatefulWidget {
  final Widget child;
  const StartupWrapper({super.key, required this.child});

  @override
  State<StartupWrapper> createState() => _StartupWrapperState();
}

class _StartupWrapperState extends State<StartupWrapper>
    with SingleTickerProviderStateMixin {
  bool   _ready   = false;
  bool   _failed  = false;
  String _status  = 'Se pornește serviciul...';
  int    _attempt = 0;

  // Pe Windows asteptam mai mult (backend porneste local)
  // Pe Android discovery e rapid, iar dupa aia health-check
  int get _maxAttempts => Platform.isAndroid ? 8 : 20;

  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _start();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    // Cu server in cloud stim adresa dinainte — sarim peste descoperire.
    if (!usesCloudBackend && Platform.isAndroid) {
      await _discoverServer();
    }
    await _checkBackend();
  }

  /// Descopera IP-ul serverului prin UDP broadcast (doar Android).
  Future<void> _discoverServer() async {
    if (!mounted) return;

    final ip = await ServerDiscovery.discover(
      onStatus: (msg) {
        if (mounted) setState(() => _status = msg);
      },
    );

    if (ip != null) {
      setDiscoveredServerIp(ip);
      if (mounted) setState(() => _status = 'Server găsit la $ip');
    } else {
      // Discovery a esuat — vom incerca oricum health-check
      // (poate cache-ul din API client e deja bun)
      if (mounted) setState(() => _status = 'Se conectează direct...');
    }
  }

  Future<void> _checkBackend() async {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 2),
      receiveTimeout: const Duration(seconds: 2),
    ));

    while (_attempt < _maxAttempts) {
      _attempt++;
      if (!mounted) return;

      setState(() {
        _status = _attempt == 1
            ? (Platform.isAndroid ? 'Se conectează la server...' : 'Se pornește serviciul...')
            : 'Se conectează... ($_attempt/$_maxAttempts)';
      });

      try {
        final url = backendBaseUrl.replaceFirst('/api/v1', '/health');
        await dio.get(url);
        if (!mounted) return;

        setState(() => _status = 'Se verifică actualizări...');
        await _checkUpdate();
        if (!mounted) return;

        setState(() { _ready = true; _status = 'Conectat!'; });
        return;
      } catch (_) {
        // In retea locala, daca health-check-ul esueaza, IP-ul serverului
        // s-ar putea sa se fi schimbat — reluam descoperirea.
        if (!usesCloudBackend && Platform.isAndroid && _attempt == 3) {
          await ServerDiscovery.clearCache();
          await _discoverServer();
        }
        await Future.delayed(const Duration(milliseconds: 1500));
      }
    }

    if (mounted) setState(() => _failed = true);
  }

  Future<void> _checkUpdate() async {
    if (!Platform.isWindows) return;
    final info = await UpdateService().checkForUpdate();
    if (info == null || !info.updateAvailable) return;
    if (!mounted) return;

    final accepted = await showUpdateDialog(context, info);
    if (accepted != true || !mounted) return;

    await UpdateService().downloadAndInstall(
      info, context,
      onProgress: () { if (mounted) setState(() {}); },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.child;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _pulse,
                child: const Icon(
                  Icons.directions_car_rounded,
                  size: 90,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'CarRecords',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),

              if (!_failed) ...[
                const SizedBox(
                  width: 36, height: 36,
                  child: CircularProgressIndicator(
                    color: Colors.white60,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ] else ...[
                const Icon(Icons.cloud_off, color: Colors.white54, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Server negăsit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Platform.isAndroid
                      ? 'Asigură-te că PC-ul este pornit și\nconectat la aceeași rețea Wi-Fi.'
                      : 'Asigură-te că aplicația este instalată\ncorect și încearcă din nou.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _failed  = false;
                      _attempt = 0;
                      _status  = 'Se reconectează...';
                    });
                    _start();
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Caută din nou'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(200, 46),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
