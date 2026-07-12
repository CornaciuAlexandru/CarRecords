import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/documents.dart';
import '../../../core/services/car_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/cm_text_field.dart';
import '../../../shared/widgets/cm_button.dart';
import 'maintenance_screen.dart';

class AddMaintenanceScreen extends ConsumerStatefulWidget {
  final String carId;
  final MaintenanceRecord? existing;
  const AddMaintenanceScreen({super.key, required this.carId, this.existing});

  @override
  ConsumerState<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends ConsumerState<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl        = TextEditingController();
  final _mileageCtrl     = TextEditingController();
  final _nextMileageCtrl = TextEditingController();
  final _shopCtrl        = TextEditingController();
  final _cityCtrl        = TextEditingController();
  final _costCtrl        = TextEditingController();
  final _invoiceCtrl     = TextEditingController();
  final _notesCtrl       = TextEditingController();

  late String _type;
  late DateTime _date;
  DateTime? _nextDate;
  bool _isLoading = false;

  bool get _isEditing => widget.existing != null;

  static const _types = {
    'schimb_ulei': 'Schimb ulei', 'filtre': 'Filtre', 'placute_frana': 'Plăcuțe frână',
    'anvelope': 'Anvelope', 'distributie': 'Distribuție', 'curea_alternator': 'Curea alternator',
    'baterie': 'Baterie', 'amortizoare': 'Amortizoare', 'bujii': 'Bujii', 'altul': 'Altul',
  };

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? 'schimb_ulei';
    _date = e?.performedDate ?? DateTime.now();
    _nextDate = e?.nextServiceDate;
    if (e != null) {
      _descCtrl.text        = e.description ?? '';
      _mileageCtrl.text     = e.mileageAtService != null ? '${e.mileageAtService}' : '';
      _nextMileageCtrl.text = e.nextServiceMileage != null ? '${e.nextServiceMileage}' : '';
      _shopCtrl.text        = e.serviceShopName ?? '';
      _cityCtrl.text        = e.city ?? '';
      _costCtrl.text        = e.cost != null ? '${e.cost}' : '';
      _invoiceCtrl.text     = e.invoiceNumber ?? '';
      _notesCtrl.text       = e.notes ?? '';
    }
  }

  Map<String, dynamic> _buildPayload() => {
    'type': _type,
    'performed_date': _date.toIso8601String().substring(0, 10),
    if (_descCtrl.text.isNotEmpty) 'description': _descCtrl.text,
    if (_mileageCtrl.text.isNotEmpty) 'mileage_at_service': int.parse(_mileageCtrl.text),
    if (_nextDate != null) 'next_service_date': _nextDate!.toIso8601String().substring(0, 10),
    if (_nextMileageCtrl.text.isNotEmpty) 'next_service_mileage': int.parse(_nextMileageCtrl.text),
    if (_shopCtrl.text.isNotEmpty) 'service_shop_name': _shopCtrl.text,
    if (_cityCtrl.text.isNotEmpty) 'city': _cityCtrl.text,
    if (_costCtrl.text.isNotEmpty) 'cost': double.parse(_costCtrl.text),
    if (_invoiceCtrl.text.isNotEmpty) 'invoice_number': _invoiceCtrl.text,
    if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text,
  };

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (_isEditing) {
        await CarService().updateMaintenance(widget.carId, widget.existing!.id, _buildPayload());
      } else {
        await CarService().createMaintenance(widget.carId, _buildPayload());
      }
      if (mounted) {
        ref.invalidate(maintenanceFutureProvider(widget.carId));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Service actualizat!' : 'Service înregistrat!'),
          backgroundColor: AppColors.success,
        ));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare: $e'), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy');
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editează service' : 'Adaugă service')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Tip intervenție *', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
              items: _types.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            CmTextField(controller: _descCtrl, label: 'Descriere', hint: 'Detalii intervenție...', maxLines: 2, prefixIcon: Icons.description_outlined),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime.now());
                if (d != null) setState(() => _date = d);
              },
              child: InputDecorator(
                decoration: InputDecoration(labelText: 'Data efectuării *', prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
                child: Text(fmt.format(_date), style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: CmTextField(controller: _mileageCtrl, label: 'Km la service', hint: '45000', keyboardType: TextInputType.number, prefixIcon: Icons.speed)),
              const SizedBox(width: 12),
              Expanded(child: CmTextField(controller: _costCtrl, label: 'Cost (RON)', hint: '350', keyboardType: TextInputType.number, prefixIcon: Icons.payments_outlined)),
            ]),
            const SizedBox(height: 16),
            const Text('Următor service (opțional)', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final d = await showDatePicker(context: context,
                        initialDate: _nextDate ?? DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now(), lastDate: DateTime(2030));
                    if (d != null) setState(() => _nextDate = d);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Data următor', prefixIcon: const Icon(Icons.event_repeat),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
                    child: Text(_nextDate != null ? fmt.format(_nextDate!) : 'Alege dată',
                        style: TextStyle(fontWeight: FontWeight.w500, color: _nextDate != null ? null : AppColors.textSecondary)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: CmTextField(controller: _nextMileageCtrl, label: 'Km următor', hint: '50000', keyboardType: TextInputType.number, prefixIcon: Icons.speed_outlined)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: CmTextField(controller: _shopCtrl, label: 'Service auto', hint: 'Dacia Service', prefixIcon: Icons.build_outlined)),
              const SizedBox(width: 12),
              Expanded(child: CmTextField(controller: _cityCtrl, label: 'Oraș', hint: 'București', prefixIcon: Icons.location_city_outlined)),
            ]),
            const SizedBox(height: 14),
            CmTextField(controller: _invoiceCtrl, label: 'Nr. factură', hint: 'F-001234', prefixIcon: Icons.receipt_long),
            const SizedBox(height: 14),
            CmTextField(controller: _notesCtrl, label: 'Note', hint: 'Observații...', maxLines: 2, prefixIcon: Icons.notes),
            const SizedBox(height: 28),
            CmButton(label: _isEditing ? 'Actualizează' : 'Salvează', icon: Icons.save,
                isLoading: _isLoading, onPressed: _isLoading ? null : _save),
          ],
        ),
      ),
    );
  }
}
