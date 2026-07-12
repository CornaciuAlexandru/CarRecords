import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _discoveryPort    = 8765;
const _discoveryMsg     = 'CARRECORDS_DISCOVER';
const _responsePrefix   = 'CARRECORDS_HERE:';
const _backendPort      = 8000;
const _cachedIpKey      = 'server_ip';

/// Descopera automat IP-ul backend-ului pe retea locala.
///
/// Ordinea de incercare:
///   1. IP-ul salvat din sesiunea anterioara (rapid)
///   2. Broadcast UDP — gaseste serverul pe orice IP
///
/// Returneaza IP-ul gasit sau `null` daca nu s-a gasit nimic.
class ServerDiscovery {
  static Future<String?> discover({
    void Function(String status)? onStatus,
  }) async {
    // ── 1. Incearca IP-ul din cache ──────────────────────────────────────
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cachedIpKey);
    if (cached != null) {
      onStatus?.call('Se verifică serverul cunoscut...');
      if (await _isReachable(cached)) {
        return cached;
      }
    }

    // ── 2. Broadcast UDP ─────────────────────────────────────────────────
    onStatus?.call('Se caută serverul în rețea...');
    final ip = await _broadcastDiscover();
    if (ip != null) {
      await prefs.setString(_cachedIpKey, ip);
    }
    return ip;
  }

  /// Sterge IP-ul din cache (apelat cand conexiunea esueaza repetat).
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedIpKey);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  static Future<bool> _isReachable(String ip) async {
    try {
      await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 2),
        receiveTimeout: const Duration(seconds: 2),
      )).get('http://$ip:$_backendPort/health');
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> _broadcastDiscover() async {
    RawDatagramSocket? sock;
    try {
      sock = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      sock.broadcastEnabled = true;

      final msg = _discoveryMsg.codeUnits;

      // Trimite pe broadcast general
      sock.send(msg, InternetAddress('255.255.255.255'), _discoveryPort);

      // Trimite si pe subnet-urile comune de hotspot Android
      for (final subnet in ['192.168.43.255', '192.168.0.255', '192.168.1.255']) {
        try {
          sock.send(msg, InternetAddress(subnet), _discoveryPort);
        } catch (_) {}
      }

      final completer = Completer<String?>();

      // Timeout 4 secunde
      final timer = Timer(const Duration(seconds: 4), () {
        if (!completer.isCompleted) completer.complete(null);
      });

      sock.listen((event) {
        if (event == RawSocketEvent.read) {
          final dg = sock!.receive();
          if (dg != null) {
            final resp = String.fromCharCodes(dg.data).trim();
            if (resp.startsWith(_responsePrefix)) {
              timer.cancel();
              if (!completer.isCompleted) {
                completer.complete(dg.address.address);
              }
            }
          }
        }
      });

      final result = await completer.future;
      return result;
    } catch (_) {
      return null;
    } finally {
      sock?.close();
    }
  }
}
