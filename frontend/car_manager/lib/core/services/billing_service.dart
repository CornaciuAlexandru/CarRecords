import 'package:dio/dio.dart';

import '../api/api_client.dart';

/// Un plan sau un pachet, asa cum il descrie serverul.
///
/// Preturile nu sunt scrise in aplicatie: vin de la `/billing/catalog`. Altfel
/// o schimbare de pret ar cere o versiune noua in magazin, iar ecranul ar putea
/// arata altceva decat se incaseaza.
class BillingPlan {
  final String productId;
  final String kind;
  final double priceEur;
  final String label;
  final String? tier;
  final int scans;
  final int? maxCars;

  const BillingPlan({
    required this.productId,
    required this.kind,
    required this.priceEur,
    required this.label,
    this.tier,
    this.scans = 0,
    this.maxCars,
  });

  bool get isSubscription => kind == 'subscription';

  factory BillingPlan.fromJson(Map<String, dynamic> j) => BillingPlan(
        productId: j['product_id'],
        kind: j['kind'],
        priceEur: (j['price_eur'] as num).toDouble(),
        label: j['label'],
        tier: j['tier'],
        scans: j['scans'] ?? 0,
        maxCars: j['max_cars'],
      );
}

class BillingService {
  final Dio _dio = createDio();

  Future<List<BillingPlan>> catalog() async {
    final resp = await _dio.get('/billing/catalog');
    return (resp.data as List)
        .map((j) => BillingPlan.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
