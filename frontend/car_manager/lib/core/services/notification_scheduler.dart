import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Mementouri pentru expirarea documentelor, programate pe telefon.
///
/// De ce local si nu push de la server: datele de expirare se stiu cu luni
/// inainte. Telefonul isi poate pune singur alarmele, iar ele suna si daca
/// serverul e picat, si daca telefonul n-are internet in ziua respectiva.
/// Un sistem de push ar adauga Firebase, chei, un job pe server si inca un
/// punct de defectare, ca sa livreze acelasi lucru mai putin sigur.
///
/// Serverul ramane sursa unica pentru praguri si texte: el spune CAND si CE
/// prin `/notifications/schedule`, aici doar se pune ceasul.
class NotificationScheduler {
  NotificationScheduler._();
  static final instance = NotificationScheduler._();

  static const _channelId = 'expirari_documente';
  static const _channelName = 'Expirari documente';
  static const _channelDescription =
      'Anunta inainte sa expire ITP-ul, asigurarea sau rovinieta.';

  /// Ora la care suna. Dimineata devreme e inutil, seara tarziu se pierde
  /// printre notificarile zilei.
  static const _hour = 9;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  Timer? _debounce;

  /// Windows si web nu programeaza nimic: pe desktop aplicatia nu sta pornita
  /// ca sa poata suna, iar utilizatorul isi vede oricum lista la deschidere.
  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // -- Pornire ---------------------------------------------------

  /// Se cheama o singura data, la pornirea aplicatiei. Nu arunca niciodata:
  /// o problema la notificari nu are voie sa opreasca aplicatia.
  Future<void> initialize() async {
    if (!isSupported || _ready) return;
    try {
      tzdata.initializeTimeZones();
      // Fara fusul real, o alarma pusa la 09:00 ar suna dupa ora UTC.
      tz.setLocalLocation(
          tz.getLocation(await FlutterTimezone.getLocalTimezone()));

      await _plugin.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // Permisiunea se cere separat, dupa ce utilizatorul a vazut la ce
          // foloseste - nu in secunda in care deschide aplicatia prima oara.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ));

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
          ));

      _ready = true;
    } catch (e) {
      debugPrint('Notificari: initializare esuata ($e)');
    }
  }

  /// Cere permisiunea de notificari (Android 13+ si iOS) si, pe Android,
  /// dreptul de a pune alarme exacte.
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    if (!_ready) await initialize();
    try {
      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted =
            await android?.requestNotificationsPermission() ?? false;
        // Fara alarme exacte Android amana livrarea ca sa economiseasca
        // bateria, iar un memento de ITP intarziat cu o zi nu mai ajuta.
        // Daca refuza, tot programam - doar mai putin precis.
        await android?.requestExactAlarmsPermission();
        return granted;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(
              alert: true, badge: true, sound: true) ??
          false;
    } catch (e) {
      debugPrint('Notificari: permisiune refuzata sau indisponibila ($e)');
      return false;
    }
  }

  // -- Sincronizare ----------------------------------------------

  /// Cere serverului lista de alarme viitoare si o pune pe telefon.
  ///
  /// Se sterge tot si se programeaza din nou, in loc sa se calculeze
  /// diferenta: lista are cateva zeci de intrari, iar o resincronizare
  /// completa nu poate lasa in urma o alarma pentru o data stearsa intre timp.
  /// Returneaza cate alarme au fost puse.
  Future<int> sync(Dio dio) async {
    if (!isSupported) return 0;
    if (!_ready) await initialize();
    if (!_ready) return 0;

    List<dynamic> items;
    try {
      final res = await dio.get('/notifications/schedule');
      items = res.data as List<dynamic>;
    } catch (e) {
      // Offline sau server picat: alarmele deja programate raman pe telefon
      // si suna oricum. Exact de asta le tinem local.
      debugPrint('Notificari: sincronizare esuata ($e)');
      return 0;
    }

    try {
      await _plugin.cancelAll();
    } catch (_) {
      return 0;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    var scheduled = 0;
    for (final raw in items) {
      final item = raw as Map<String, dynamic>;
      final when = _fireInstant(item['fire_on'] as String);
      if (when == null) continue;
      try {
        await _plugin.zonedSchedule(
          _idFor(item['key'] as String),
          item['title'] as String,
          item['body'] as String,
          when,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: item['car_id'] as String?,
        );
        scheduled++;
      } catch (e) {
        // O alarma respinsa (permisiune lipsa, data imposibila) nu trebuie sa
        // le opreasca pe celelalte.
        debugPrint('Notificari: nu am putut programa alarma ($e)');
      }
    }
    return scheduled;
  }

  /// Resincronizare amanata, pentru cand se salveaza documente unul dupa
  /// altul: asteapta sa se linisteasca si face o singura trecere.
  void scheduleResync(Dio dio) {
    if (!isSupported) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 3), () => sync(dio));
  }

  /// La delogare nu mai are ce suna: datele nu mai sunt ale acestui telefon.
  Future<void> cancelAll() async {
    if (!isSupported || !_ready) return;
    _debounce?.cancel();
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  // -- Ajutoare --------------------------------------------------

  /// Momentul exact in care suna alarma pentru o zi data.
  ///
  /// Daca ziua e chiar azi si ora a trecut deja, suna peste un minut in loc sa
  /// se piarda: utilizatorul tot trebuie sa afle azi. O data din trecut e
  /// respinsa - `zonedSchedule` arunca pe ea.
  tz.TZDateTime? _fireInstant(String isoDate) {
    final day = DateTime.parse(isoDate);
    final now = tz.TZDateTime.now(tz.local);
    final at = tz.TZDateTime(tz.local, day.year, day.month, day.day, _hour);
    if (at.isAfter(now)) return at;
    final sameDay =
        at.year == now.year && at.month == now.month && at.day == now.day;
    return sameDay ? now.add(const Duration(minutes: 1)) : null;
  }

  /// Id numeric stabil pentru o cheie. Aceeasi cheie da acelasi id la fiecare
  /// sincronizare, deci o alarma nu ajunge programata de doua ori.
  int _idFor(String key) {
    var hash = 0;
    for (final unit in key.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }
}
