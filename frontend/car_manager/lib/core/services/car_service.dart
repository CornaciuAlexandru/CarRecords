import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/documents.dart';
import '../api/api_client.dart';

class CarService {
  final Dio _dio = createDio();

  Future<List<Car>> getCars() async {
    final resp = await _dio.get('/cars');
    return (resp.data as List).map((j) => Car.fromJson(j)).toList();
  }

  Future<Car> createCar(Map<String, dynamic> data) async {
    final resp = await _dio.post('/cars', data: data);
    return Car.fromJson(resp.data);
  }

  Future<Car> updateCar(String carId, Map<String, dynamic> data) async {
    final resp = await _dio.put('/cars/$carId', data: data);
    return Car.fromJson(resp.data);
  }

  Future<void> deleteCar(String carId) async {
    await _dio.delete('/cars/$carId');
  }

  // ── Roviniete ──────────────────────────────────────────────
  Future<List<Vignette>> getVignettes(String carId) async {
    final resp = await _dio.get('/cars/$carId/vignettes');
    return (resp.data as List).map((j) => Vignette.fromJson(j)).toList();
  }

  Future<Vignette> createVignette(String carId, Map<String, dynamic> data) async {
    final resp = await _dio.post('/cars/$carId/vignettes', data: data);
    return Vignette.fromJson(resp.data);
  }

  Future<Vignette> updateVignette(String carId, String vigId, Map<String, dynamic> data) async {
    final resp = await _dio.put('/cars/$carId/vignettes/$vigId', data: data);
    return Vignette.fromJson(resp.data);
  }

  Future<void> deleteVignette(String carId, String vigId) async {
    await _dio.delete('/cars/$carId/vignettes/$vigId');
  }

  Future<Map<String, dynamic>> scanVignette(String carId, String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: 'scan.jpg'),
    });
    final resp = await _dio.post('/cars/$carId/vignettes/scan', data: formData);
    return resp.data;
  }

  // ── Asigurari ──────────────────────────────────────────────
  Future<List<InsurancePolicy>> getInsurance(String carId) async {
    final resp = await _dio.get('/cars/$carId/insurance');
    return (resp.data as List).map((j) => InsurancePolicy.fromJson(j)).toList();
  }

  Future<InsurancePolicy> createInsurance(String carId, Map<String, dynamic> data) async {
    final resp = await _dio.post('/cars/$carId/insurance', data: data);
    return InsurancePolicy.fromJson(resp.data);
  }

  Future<InsurancePolicy> updateInsurance(String carId, String policyId, Map<String, dynamic> data) async {
    final resp = await _dio.put('/cars/$carId/insurance/$policyId', data: data);
    return InsurancePolicy.fromJson(resp.data);
  }

  Future<void> deleteInsurance(String carId, String policyId) async {
    await _dio.delete('/cars/$carId/insurance/$policyId');
  }

  Future<Map<String, dynamic>> scanInsurance(String carId, String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: 'scan.jpg'),
    });
    final resp = await _dio.post('/cars/$carId/insurance/scan', data: formData);
    return resp.data;
  }

  // ── Inregistrare / ITP ─────────────────────────────────────
  Future<List<VehicleRegistration>> getRegistrations(String carId) async {
    final resp = await _dio.get('/cars/$carId/registration');
    return (resp.data as List).map((j) => VehicleRegistration.fromJson(j)).toList();
  }

  Future<VehicleRegistration> createRegistration(String carId, Map<String, dynamic> data) async {
    final resp = await _dio.post('/cars/$carId/registration', data: data);
    return VehicleRegistration.fromJson(resp.data);
  }

  Future<VehicleRegistration> updateRegistration(String carId, String regId, Map<String, dynamic> data) async {
    final resp = await _dio.put('/cars/$carId/registration/$regId', data: data);
    return VehicleRegistration.fromJson(resp.data);
  }

  Future<void> deleteRegistration(String carId, String regId) async {
    await _dio.delete('/cars/$carId/registration/$regId');
  }

  Future<Map<String, dynamic>> scanRegistration(String carId, String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: 'scan.jpg'),
    });
    final resp = await _dio.post('/cars/$carId/registration/scan', data: formData);
    return resp.data;
  }

  // ── Mentenanta ─────────────────────────────────────────────
  Future<List<MaintenanceRecord>> getMaintenance(String carId) async {
    final resp = await _dio.get('/cars/$carId/maintenance');
    return (resp.data as List).map((j) => MaintenanceRecord.fromJson(j)).toList();
  }

  Future<MaintenanceRecord> createMaintenance(String carId, Map<String, dynamic> data) async {
    final resp = await _dio.post('/cars/$carId/maintenance', data: data);
    return MaintenanceRecord.fromJson(resp.data);
  }

  Future<MaintenanceRecord> updateMaintenance(String carId, String recordId, Map<String, dynamic> data) async {
    final resp = await _dio.put('/cars/$carId/maintenance/$recordId', data: data);
    return MaintenanceRecord.fromJson(resp.data);
  }

  Future<void> deleteMaintenance(String carId, String recordId) async {
    await _dio.delete('/cars/$carId/maintenance/$recordId');
  }

  // ── Modificari ─────────────────────────────────────────────
  Future<List<CarModification>> getModifications(String carId) async {
    final resp = await _dio.get('/cars/$carId/modifications');
    return (resp.data as List).map((j) => CarModification.fromJson(j)).toList();
  }

  Future<CarModification> createModification(String carId, Map<String, dynamic> data) async {
    final resp = await _dio.post('/cars/$carId/modifications', data: data);
    return CarModification.fromJson(resp.data);
  }

  Future<CarModification> updateModification(String carId, String modId, Map<String, dynamic> data) async {
    final resp = await _dio.put('/cars/$carId/modifications/$modId', data: data);
    return CarModification.fromJson(resp.data);
  }

  Future<void> deleteModification(String carId, String modId) async {
    await _dio.delete('/cars/$carId/modifications/$modId');
  }

  Future<String> uploadModificationPhoto(String carId, String modId, String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath,
          filename: filePath.split(RegExp(r'[/\\]')).last),
    });
    final resp = await _dio.post('/cars/$carId/modifications/$modId/photos',
        data: formData);
    return resp.data['photo_url'] as String;
  }

  // ── Notificari ─────────────────────────────────────────────
  Future<List<AppNotification>> getNotifications({bool unreadOnly = false}) async {
    final resp = await _dio.get('/notifications',
        queryParameters: unreadOnly ? {'unread_only': true} : null);
    return (resp.data as List).map((j) => AppNotification.fromJson(j)).toList();
  }

  Future<void> markNotificationRead(String id) async {
    await _dio.put('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _dio.put('/notifications/read-all');
  }

  Future<int> checkNotifications() async {
    final resp = await _dio.post('/notifications/check');
    return resp.data['created'] ?? 0;
  }
}
