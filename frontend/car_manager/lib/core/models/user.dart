class User {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String role;
  final bool isActive;
  final String subscriptionTier;
  final int maxCars;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    required this.isActive,
    required this.subscriptionTier,
    required this.maxCars,
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isPremium => subscriptionTier == 'premium';

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'],
        email: j['email'],
        fullName: j['full_name'],
        phone: j['phone'],
        role: j['role'],
        isActive: j['is_active'],
        subscriptionTier: j['subscription_tier'],
        maxCars: j['max_cars'],
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
