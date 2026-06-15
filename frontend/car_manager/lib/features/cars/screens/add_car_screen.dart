import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cars_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/cm_text_field.dart';
import '../../../shared/widgets/cm_button.dart';

class AddCarScreen extends ConsumerStatefulWidget {
  const AddCarScreen({super.key});
  @override
  ConsumerState<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends ConsumerState<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _vinCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _powerCtrl = TextEditingController();
  String? _fuelType;
  bool _isLoading = false;

  static const _fuels = ['benzina', 'motorina', 'hybrid', 'electric', 'gpl'];

  @override
  void dispose() {
    for (final c in [_nicknameCtrl, _brandCtrl, _modelCtrl, _yearCtrl,
      _plateCtrl, _vinCtrl, _mileageCtrl, _capacityCtrl, _powerCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(carsProvider.notifier).addCar({
        if (_nicknameCtrl.text.isNotEmpty) 'nickname': _nicknameCtrl.text.trim(),
        'brand': _brandCtrl.text.trim(),
        'model': _modelCtrl.text.trim(),
        'year': int.parse(_yearCtrl.text),
        'license_plate': _plateCtrl.text.trim().toUpperCase(),
        if (_vinCtrl.text.isNotEmpty) 'vin_number': _vinCtrl.text.trim(),
        if (_mileageCtrl.text.isNotEmpty) 'mileage': int.parse(_mileageCtrl.text),
        if (_capacityCtrl.text.isNotEmpty) 'engine_capacity': int.parse(_capacityCtrl.text),
        if (_powerCtrl.text.isNotEmpty) 'engine_power': int.parse(_powerCtrl.text),
        if (_fuelType != null) 'fuel_type': _fuelType,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mașina a fost adăugată!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      final msg = e is DioException
          ? (e.response?.data?['detail'] ?? 'Eroare la salvare')
          : e.toString();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.toString()), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adaugă mașină')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionTitle('Informații generale'),
            CmTextField(controller: _nicknameCtrl, label: 'Poreclă (opțional)', hint: 'Ex: Daciuța mea',
                prefixIcon: Icons.label_outline),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: CmTextField(controller: _brandCtrl, label: 'Marcă *', hint: 'Dacia',
                  prefixIcon: Icons.branding_watermark_outlined,
                  validator: (v) => (v == null || v.isEmpty) ? 'Obligatoriu' : null)),
              const SizedBox(width: 12),
              Expanded(child: CmTextField(controller: _modelCtrl, label: 'Model *', hint: 'Logan',
                  validator: (v) => (v == null || v.isEmpty) ? 'Obligatoriu' : null)),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: CmTextField(controller: _yearCtrl, label: 'An fabricație *',
                  hint: '2020', keyboardType: TextInputType.number,
                  prefixIcon: Icons.calendar_today,
                  validator: (v) {
                    final y = int.tryParse(v ?? '');
                    if (y == null || y < 1900 || y > 2030) return 'An invalid';
                    return null;
                  })),
              const SizedBox(width: 12),
              Expanded(child: CmTextField(controller: _plateCtrl, label: 'Număr înmatr. *',
                  hint: 'B-123-XYZ',
                  validator: (v) => (v == null || v.isEmpty) ? 'Obligatoriu' : null)),
            ]),
            const SizedBox(height: 20),
            _sectionTitle('Detalii tehnice'),
            DropdownButtonFormField<String>(
              value: _fuelType,
              decoration: InputDecoration(
                labelText: 'Combustibil',
                prefixIcon: const Icon(Icons.local_gas_station_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.white,
              ),
              items: _fuels.map((f) => DropdownMenuItem(value: f,
                  child: Text(f[0].toUpperCase() + f.substring(1)))).toList(),
              onChanged: (v) => setState(() => _fuelType = v),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: CmTextField(controller: _capacityCtrl, label: 'Cilindree (cc)',
                  hint: '1000', keyboardType: TextInputType.number, prefixIcon: Icons.settings_outlined)),
              const SizedBox(width: 12),
              Expanded(child: CmTextField(controller: _powerCtrl, label: 'Putere (CP)',
                  hint: '90', keyboardType: TextInputType.number, prefixIcon: Icons.speed)),
            ]),
            const SizedBox(height: 14),
            CmTextField(controller: _mileageCtrl, label: 'Kilometraj actual', hint: '45000',
                keyboardType: TextInputType.number, prefixIcon: Icons.speed_outlined),
            const SizedBox(height: 14),
            CmTextField(controller: _vinCtrl, label: 'Serie șasiu (VIN)', hint: '1HGBH41JXMN109186',
                prefixIcon: Icons.confirmation_number_outlined),
            const SizedBox(height: 28),
            CmButton(label: 'Salvează mașina', isLoading: _isLoading,
                icon: Icons.check, onPressed: _isLoading ? null : _save),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16,
        color: AppColors.primary)),
  );
}
