import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user.dart';
import '../../../core/services/car_service.dart';
import '../../auth/providers/auth_provider.dart';

final carServiceProvider = Provider((_) => CarService());

final carsProvider = AsyncNotifierProvider<CarsNotifier, List<Car>>(CarsNotifier.new);

class CarsNotifier extends AsyncNotifier<List<Car>> {
  @override
  Future<List<Car>> build() async {
    // Rebuild-uieste automat cand utilizatorul se schimba (login/logout)
    final authState = ref.watch(authStateProvider);
    if (authState.value == null) return [];
    return ref.read(carServiceProvider).getCars();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(carServiceProvider).getCars());
  }

  Future<Car> addCar(Map<String, dynamic> data) async {
    final car = await ref.read(carServiceProvider).createCar(data);
    state = AsyncData([...state.value ?? [], car]);
    return car;
  }

  Future<void> updateCar(String carId, Map<String, dynamic> data) async {
    final updated = await ref.read(carServiceProvider).updateCar(carId, data);
    state = AsyncData(
      (state.value ?? []).map((c) => c.id == carId ? updated : c).toList(),
    );
  }

  Future<void> deleteCar(String carId) async {
    await ref.read(carServiceProvider).deleteCar(carId);
    state = AsyncData((state.value ?? []).where((c) => c.id != carId).toList());
  }
}

final selectedCarProvider = StateProvider<Car?>((ref) => null);
