import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Gestionarea reclamelor (AdMob).
///
/// Reclamele apar doar pe Android si iOS — pe Windows pachetul nu are
/// implementare, iar toate metodele de aici devin operatii goale.
///
/// ID-URI: implicit sunt cele de TEST oferite de Google, sigure in
/// dezvoltare. Inainte de publicare inlocuieste-le cu cele reale din
/// contul tau AdMob (vezi `docs/reclame.md`), altfel Google poate
/// suspenda contul pentru clicuri pe reclame de test in productie.
class AdsService {
  AdsService._();
  static final instance = AdsService._();

  // ── Comutator general ────────────────────────────────────────
  // Reclamele se pot dezactiva complet la compilare:
  //   flutter build apk --release --dart-define=ADS_ENABLED=false
  static const _adsEnabled =
      bool.fromEnvironment('ADS_ENABLED', defaultValue: true);

  /// ID-urile reale se dau la compilare:
  ///   --dart-define=ADMOB_BANNER=ca-app-pub-XXXX/YYYY
  static const _bannerIdOverride = String.fromEnvironment('ADMOB_BANNER');
  static const _interstitialIdOverride =
      String.fromEnvironment('ADMOB_INTERSTITIAL');

  // ID-uri de TEST oficiale Google
  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  bool _initialized = false;
  bool _consentGathered = false;
  InterstitialAd? _interstitial;
  int _actionsSinceLastAd = 0;

  /// Cate actiuni (salvari de documente) intre doua reclame pe tot ecranul.
  /// Prea des devine enervant si creste dezinstalarile.
  static const _actionsBetweenInterstitials = 4;

  /// Platformele pe care exista reclame.
  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool get enabled => _adsEnabled && isSupported;

  // ── Initializare ─────────────────────────────────────────────

  /// Porneste SDK-ul si cere consimtamantul pentru utilizatorii din UE.
  /// Se apeleaza o singura data, la pornirea aplicatiei.
  Future<void> initialize() async {
    if (!enabled || _initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      await _gatherConsent();
      _preloadInterstitial();
    } catch (e) {
      debugPrint('AdsService: initializare esuata — $e');
    }
  }

  /// Formularul de consimtamant GDPR (Google UMP).
  ///
  /// Obligatoriu in UE: fara consimtamant nu se pot afisa reclame
  /// personalizate, iar Google poate bloca contul. Formularul apare o
  /// singura data; alegerea se retine de catre SDK.
  Future<void> _gatherConsent() {
    if (_consentGathered) return Future.value();
    final completer = Completer<void>();
    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          if (await ConsentInformation.instance.isConsentFormAvailable()) {
            ConsentForm.loadAndShowConsentFormIfRequired((_) {
              _consentGathered = true;
              if (!completer.isCompleted) completer.complete();
            });
          } else {
            _consentGathered = true;
            if (!completer.isCompleted) completer.complete();
          }
        },
        (error) {
          debugPrint('AdsService: consimtamant — ${error.message}');
          if (!completer.isCompleted) completer.complete();
        },
      );
    } catch (e) {
      debugPrint('AdsService: consimtamant esuat — $e');
      if (!completer.isCompleted) completer.complete();
    }
    return completer.future;
  }

  /// Redeschide formularul de confidentialitate, pentru ca utilizatorul
  /// sa-si poata schimba alegerea (cerinta GDPR).
  Future<void> showPrivacyOptions() async {
    if (!enabled) return;
    try {
      await ConsentForm.showPrivacyOptionsForm((_) {});
    } catch (e) {
      debugPrint('AdsService: optiuni confidentialitate — $e');
    }
  }

  /// Daca exista optiuni de confidentialitate de aratat in Profil.
  Future<bool> get privacyOptionsRequired async {
    if (!enabled) return false;
    try {
      return await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  // ── Identificatori ───────────────────────────────────────────

  String get bannerUnitId {
    if (_bannerIdOverride.isNotEmpty) return _bannerIdOverride;
    return Platform.isAndroid ? _testBannerAndroid : _testBannerIos;
  }

  String get interstitialUnitId {
    if (_interstitialIdOverride.isNotEmpty) return _interstitialIdOverride;
    return Platform.isAndroid ? _testInterstitialAndroid : _testInterstitialIos;
  }

  /// Adevarat cand se folosesc inca ID-urile de test.
  bool get usingTestIds =>
      _bannerIdOverride.isEmpty || _interstitialIdOverride.isEmpty;

  // ── Reclama pe tot ecranul ───────────────────────────────────

  void _preloadInterstitial() {
    if (!enabled || _interstitial != null) return;
    InterstitialAd.load(
      adUnitId: interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              _preloadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              _interstitial = null;
              _preloadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdsService: interstitial — ${error.message}');
          _interstitial = null;
        },
      ),
    );
  }

  /// De apelat dupa o actiune importanta (salvarea unui document).
  /// Reclama apare doar la fiecare a N-a actiune, nu de fiecare data.
  Future<void> onUserAction() async {
    if (!enabled) return;
    _actionsSinceLastAd++;
    if (_actionsSinceLastAd < _actionsBetweenInterstitials) return;

    final ad = _interstitial;
    if (ad == null) {
      _preloadInterstitial();
      return;
    }
    _actionsSinceLastAd = 0;
    _interstitial = null;
    await ad.show();
  }

  void dispose() {
    _interstitial?.dispose();
    _interstitial = null;
  }
}
