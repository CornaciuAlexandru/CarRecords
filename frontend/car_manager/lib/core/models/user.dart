class User {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String role;
  final bool isActive;
  final bool emailVerified;
  final String subscriptionTier;
  final int maxCars;
  /// Scanari OCR cumparate separat, folosibile pe orice masina a contului.
  final int scanCredits;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    required this.isActive,
    this.emailVerified = false,
    required this.subscriptionTier,
    required this.maxCars,
    this.scanCredits = 0,
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  /// Planurile platite. Serverul le verifica oricum la fiecare cerere - asta e
  /// doar ca sa nu ducem omul pana la un buton care s-ar refuza.
  bool get isPaid => subscriptionTier == 'pro' || subscriptionTier == 'maxi';

  String get planLabel => switch (subscriptionTier) {
        'pro' => 'PRO',
        'maxi' => 'MAXI',
        _ => 'Gratuit',
      };

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'],
        email: j['email'],
        fullName: j['full_name'],
        phone: j['phone'],
        role: j['role'],
        isActive: j['is_active'],
        emailVerified: j['email_verified'] ?? false,
        subscriptionTier: j['subscription_tier'],
        maxCars: j['max_cars'],
        scanCredits: j['scan_credits'] ?? 0,
        createdAt: j['created_at'] != null ? DateTime.tryParse(j['created_at']) : null,
      );
}

// Model extins pentru panoul de administrare
class AdminUserInfo {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String role;
  final bool isActive;
  final String subscriptionTier;
  final int maxCars;
  final DateTime? createdAt;
  final int carCount;
  final int recordsCount;

  const AdminUserInfo({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    required this.isActive,
    required this.subscriptionTier,
    required this.maxCars,
    this.createdAt,
    required this.carCount,
    required this.recordsCount,
  });

  bool get isAdmin => role == 'admin';

  factory AdminUserInfo.fromJson(Map<String, dynamic> j) => AdminUserInfo(
        id: j['id'],
        email: j['email'],
        fullName: j['full_name'],
        phone: j['phone'],
        role: j['role'],
        isActive: j['is_active'],
        subscriptionTier: j['subscription_tier'],
        maxCars: j['max_cars'],
        createdAt: j['created_at'] != null ? DateTime.tryParse(j['created_at']) : null,
        carCount: j['car_count'] ?? 0,
        recordsCount: j['records_count'] ?? 0,
      );
}

class Car {
  final String id;
  final String userId;
  final String? nickname;
  final String brand;
  final String model;
  final int year;
  final String? color;
  final String? vinNumber;
  final int? engineCapacity;
  final String? fuelType;
  final int? enginePower;
  final String licensePlate;
  final String? registrationNumber;
  final int? mileage;
  /// Scanari OCR folosite din cele incluse cu masina, si cate au mai ramas.
  /// Vin de la server: limitele nu se calculeaza in aplicatie.
  final int ocrScans;
  final int ocrScansLeft;

  const Car({
    required this.id,
    required this.userId,
    this.nickname,
    required this.brand,
    required this.model,
    required this.year,
    this.color,
    this.vinNumber,
    this.engineCapacity,
    this.fuelType,
    this.enginePower,
    required this.licensePlate,
    this.registrationNumber,
    this.mileage,
    this.ocrScans = 0,
    this.ocrScansLeft = 0,
  });

  String get displayName => nickname ?? '$brand $model ($year)';

  factory Car.fromJson(Map<String, dynamic> j) => Car(
        id: j['id'],
        userId: j['user_id'],
        nickname: j['nickname'],
        brand: j['brand'],
        model: j['model'],
        year: j['year'],
        color: j['color'],
        vinNumber: j['vin_number'],
        engineCapacity: j['engine_capacity'],
        fuelType: j['fuel_type'],
        enginePower: j['engine_power'],
        licensePlate: j['license_plate'],
        registrationNumber: j['registration_number'],
        mileage: j['mileage'],
        ocrScans: j['ocr_scans'] ?? 0,
        ocrScansLeft: j['ocr_scans_left'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        if (nickname != null) 'nickname': nickname,
        'brand': brand,
        'model': model,
        'year': year,
        if (color != null) 'color': color,
        if (vinNumber != null) 'vin_number': vinNumber,
        if (engineCapacity != null) 'engine_capacity': engineCapacity,
        if (fuelType != null) 'fuel_type': fuelType,
        if (enginePower != null) 'engine_power': enginePower,
        'license_plate': licensePlate,
        if (registrationNumber != null) 'registration_number': registrationNumber,
        if (mileage != null) 'mileage': mileage,
      };
}
