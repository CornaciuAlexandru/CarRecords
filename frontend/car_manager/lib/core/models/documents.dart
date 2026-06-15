class Vignette {
  final String id;
  final String carId;
  final DateTime purchaseDate;
  final DateTime validFrom;
  final DateTime validUntil;
  final String validityPeriod;
  final String? issuerCompany;
  final String? city;
  final double? price;
  final String currency;
  final String? invoiceNumber;
  final String? invoiceSeries;
  final String? documentImagePath;
  final String? notes;

  const Vignette({
    required this.id,
    required this.carId,
    required this.purchaseDate,
    required this.validFrom,
    required this.validUntil,
    required this.validityPeriod,
    this.issuerCompany,
    this.city,
    this.price,
    required this.currency,
    this.invoiceNumber,
    this.invoiceSeries,
    this.documentImagePath,
    this.notes,
  });

  bool get isExpired => validUntil.isBefore(DateTime.now());
  int get daysLeft => validUntil.difference(DateTime.now()).inDays;

  StatusLevel get status {
    if (isExpired) return StatusLevel.expired;
    if (daysLeft <= 7) return StatusLevel.critical;
    if (daysLeft <= 30) return StatusLevel.warning;
    return StatusLevel.ok;
  }

  factory Vignette.fromJson(Map<String, dynamic> j) => Vignette(
        id: j['id'],
        carId: j['car_id'],
        purchaseDate: DateTime.parse(j['purchase_date']),
        validFrom: DateTime.parse(j['valid_from']),
        validUntil: DateTime.parse(j['valid_until']),
        validityPeriod: j['validity_period'],
        issuerCompany: j['issuer_company'],
        city: j['city'],
        price: j['price']?.toDouble(),
        currency: j['currency'] ?? 'RON',
        invoiceNumber: j['invoice_number'],
        invoiceSeries: j['invoice_series'],
        documentImagePath: j['document_image_path'],
        notes: j['notes'],
      );
}

class InsurancePolicy {
  final String id;
  final String carId;
  final String type;
  final String? policyNumber;
  final String insurerCompany;
  final String? agentName;
  final String? agentPhone;
  final DateTime purchaseDate;
  final DateTime validFrom;
  final DateTime validUntil;
  final double? premiumAmount;
  final String currency;
  final String paymentFrequency;
  final double? deductibleAmount;
  final bool roadsideAssistance;
  final String? documentImagePath;
  final String? notes;

  const InsurancePolicy({
    required this.id,
    required this.carId,
    required this.type,
    this.policyNumber,
    required this.insurerCompany,
    this.agentName,
    this.agentPhone,
    required this.purchaseDate,
    required this.validFrom,
    required this.validUntil,
    this.premiumAmount,
    required this.currency,
    required this.paymentFrequency,
    this.deductibleAmount,
    required this.roadsideAssistance,
    this.documentImagePath,
    this.notes,
  });

  bool get isExpired => validUntil.isBefore(DateTime.now());
  int get daysLeft => validUntil.difference(DateTime.now()).inDays;

  StatusLevel get status {
    if (isExpired) return StatusLevel.expired;
    if (daysLeft <= 14) return StatusLevel.critical;
    if (daysLeft <= 45) return StatusLevel.warning;
    return StatusLevel.ok;
  }

  factory InsurancePolicy.fromJson(Map<String, dynamic> j) => InsurancePolicy(
        id: j['id'],
        carId: j['car_id'],
        type: j['type'],
        policyNumber: j['policy_number'],
        insurerCompany: j['insurer_company'],
        agentName: j['agent_name'],
        agentPhone: j['agent_phone'],
        purchaseDate: DateTime.parse(j['purchase_date']),
        validFrom: DateTime.parse(j['valid_from']),
        validUntil: DateTime.parse(j['valid_until']),
        premiumAmount: j['premium_amount']?.toDouble(),
        currency: j['currency'] ?? 'RON',
        paymentFrequency: j['payment_frequency'],
        deductibleAmount: j['deductible_amount']?.toDouble(),
        roadsideAssistance: j['roadside_assistance'] ?? false,
        documentImagePath: j['document_image_path'],
        notes: j['notes'],
      );
}

class MaintenanceRecord {
  final String id;
  final String carId;
  final String type;
  final String? description;
  final DateTime performedDate;
  final int? mileageAtService;
  final DateTime? nextServiceDate;
  final int? nextServiceMileage;
  final String? serviceShopName;
  final String? city;
  final double? cost;
  final String currency;
  final List<dynamic>? partsReplaced;
  final String? invoiceNumber;
  final String? documentImagePath;
  final String? notes;

  const MaintenanceRecord({
    required this.id,
    required this.carId,
    required this.type,
    this.description,
    required this.performedDate,
    this.mileageAtService,
    this.nextServiceDate,
    this.nextServiceMileage,
    this.serviceShopName,
    this.city,
    this.cost,
    required this.currency,
    this.partsReplaced,
    this.invoiceNumber,
    this.documentImagePath,
    this.notes,
  });

  factory MaintenanceRecord.fromJson(Map<String, dynamic> j) => MaintenanceRecord(
        id: j['id'],
        carId: j['car_id'],
        type: j['type'],
        description: j['description'],
        performedDate: DateTime.parse(j['performed_date']),
        mileageAtService: j['mileage_at_service'],
        nextServiceDate: j['next_service_date'] != null
            ? DateTime.parse(j['next_service_date'])
            : null,
        nextServiceMileage: j['next_service_mileage'],
        serviceShopName: j['service_shop_name'],
        city: j['city'],
        cost: j['cost']?.toDouble(),
        currency: j['currency'] ?? 'RON',
        partsReplaced: j['parts_replaced'],
        invoiceNumber: j['invoice_number'],
        documentImagePath: j['document_image_path'],
        notes: j['notes'],
      );
}

class CarModification {
  final String id;
  final String carId;
  final String category;
  final String description;
  final DateTime? modificationDate;
  final String? performedBy;
  final double? cost;
  final String currency;
  final bool isHomologated;
  final String? homologationNumber;
  final List<dynamic>? photos;
  final String? notes;

  const CarModification({
    required this.id,
    required this.carId,
    required this.category,
    required this.description,
    this.modificationDate,
    this.performedBy,
    this.cost,
    required this.currency,
    required this.isHomologated,
    this.homologationNumber,
    this.photos,
    this.notes,
  });

  factory CarModification.fromJson(Map<String, dynamic> j) => CarModification(
        id: j['id'],
        carId: j['car_id'],
        category: j['category'],
        description: j['description'],
        modificationDate: j['modification_date'] != null
            ? DateTime.parse(j['modification_date'])
            : null,
        performedBy: j['performed_by'],
        cost: j['cost']?.toDouble(),
        currency: j['currency'] ?? 'RON',
        isHomologated: j['is_homologated'] ?? false,
        homologationNumber: j['homologation_number'],
        photos: j['photos'],
        notes: j['notes'],
      );
}

class AppNotification {
  final String id;
  final String userId;
  final String? carId;
  final String type;
  final String title;
  final String message;
  final int? daysBeforeAlert;
  final bool isRead;
  final DateTime triggeredAt;

  const AppNotification({
    required this.id,
    required this.userId,
    this.carId,
    required this.type,
    required this.title,
    required this.message,
    this.daysBeforeAlert,
    required this.isRead,
    required this.triggeredAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'],
        userId: j['user_id'],
        carId: j['car_id'],
        type: j['type'],
        title: j['title'],
        message: j['message'],
        daysBeforeAlert: j['days_before_alert'],
        isRead: j['is_read'],
        triggeredAt: DateTime.parse(j['triggered_at']),
      );

  AppNotification copyWithRead() => AppNotification(
        id: id,
        userId: userId,
        carId: carId,
        type: type,
        title: title,
        message: message,
        daysBeforeAlert: daysBeforeAlert,
        isRead: true,
        triggeredAt: triggeredAt,
      );
}

class VehicleRegistration {
  final String id;
  final String carId;
  final String? registrationNumber;
  final DateTime? registrationDate;
  final DateTime? itpExpiryDate;
  final String? ownerName;
  final String? ownerAddress;
  final String? carSeries;
  final String? brand;
  final String? model;
  final String? manufacturingYear;
  final String? documentImagePath;
  final String? notes;

  const VehicleRegistration({
    required this.id,
    required this.carId,
    this.registrationNumber,
    this.registrationDate,
    this.itpExpiryDate,
    this.ownerName,
    this.ownerAddress,
    this.carSeries,
    this.brand,
    this.model,
    this.manufacturingYear,
    this.documentImagePath,
    this.notes,
  });

  StatusLevel? get itpStatus {
    if (itpExpiryDate == null) return null;
    final days = itpExpiryDate!.difference(DateTime.now()).inDays;
    if (days < 0) return StatusLevel.expired;
    if (days <= 7) return StatusLevel.critical;
    if (days <= 30) return StatusLevel.warning;
    return StatusLevel.ok;
  }

  factory VehicleRegistration.fromJson(Map<String, dynamic> j) => VehicleRegistration(
        id: j['id'],
        carId: j['car_id'],
        registrationNumber: j['registration_number'],
        registrationDate: j['registration_date'] != null
            ? DateTime.parse(j['registration_date'])
            : null,
        itpExpiryDate: j['itp_expiry_date'] != null
            ? DateTime.parse(j['itp_expiry_date'])
            : null,
        ownerName: j['owner_name'],
        ownerAddress: j['owner_address'],
        carSeries: j['car_series'],
        brand: j['brand'],
        model: j['model'],
        manufacturingYear: j['manufacturing_year'],
        documentImagePath: j['document_image_path'],
        notes: j['notes'],
      );
}

enum StatusLevel { ok, warning, critical, expired }
