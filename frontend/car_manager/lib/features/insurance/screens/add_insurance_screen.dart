import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/documents.dart';
import '../../../core/services/car_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/cm_text_field.dart';
import '../../../shared/widgets/cm_button.dart';
import '../../../shared/widgets/scan_card.dart';
import 'insurance_screen.dart';

class AddInsuranceScreen extends ConsumerStatefulWidget {
  final String carId;
  final String initialType;
  final InsurancePolicy? existing;
  const AddInsuranceScreen({super.key, required this.carId, this.initialType = 'RCA', this.existing});

  @override
  ConsumerState<AddInsuranceScreen> createState() => _AddInsuranceScreenState();
}

class _AddInsuranceScreenState extends ConsumerState<AddInsuranceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fmt = DateFormat('dd.MM.yyyy');

  final _insurerCtrl = TextEditingController();
  final _policyNrCtrl = TextEditingController();
  final _agentNameCtrl = TextEditingController();
  final _agentPhoneCtrl = TextEditingController();
  final _premiumCtrl = TextEditingController();
  final _deductibleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late String _type;
  late String _frequency;
  late bool _roadsideAssistance;
  late DateTime _purchaseDate;
  late DateTime _validFrom;
  late DateTime _validUntil;
  bool _isLoading = false;
  bool _isScanning = false;
  File? _scannedImage;

  bool get _isEditing => widget.existing != null;

  static const _types = ['RCA', 'CASCO', 'alta'];
  static const _frequencies = {
    'anual': 'Anual',
    'semestrial': 'Semestrial',
    'trimestrial': 'Trimestrial',
    'lunar': 'Lunar',
  };
  static const _insurers = [
    'Allianz', 'ASIROM', 'Generali', 'Omniasig', 'Groupama',
    'UNIQA', 'Gothaer', 'Grawe', 'Signal Iduna', 'Altul'
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type              = e?.type ?? widget.initialType;
    _frequency         = e?.paymentFrequency ?? 'anual';
    _roadsideAssistance = e?.roadsideAssistance ?? false;
    _purchaseDate      = e?.purchaseDate ?? DateTime.now();
    _validFrom         = e?.validFrom ?? DateTime.now();
    _validUntil        = e?.validUntil ?? DateTime.now().add(const Duration(days: 365));
    if (e != null) {
      _insurerCtrl.text    = e.insurerCompany;
      _policyNrCtrl.text   = e.policyNumber ?? '';
      _agentNameCtrl.text  = e.agentName ?? '';
      _agentPhoneCtrl.text = e.agentPhone ?? '';
      _premiumCtrl.text    = e.premiumAmount != null ? '${e.premiumAmount}' : '';
      _deductibleCtrl.text = e.deductibleAmount != null ? '${e.deductibleAmount}' : '';
      _notesCtrl.text      = e.notes ?? '';
    }
  }

  Future<void> _scan(String filePath) async {
    setState(() { _scannedImage = File(filePath); _isScanning = true; });
    try {
      final result = await CarService().scanInsurance(widget.carId, filePath);
      final data = result['extracted_data'] as Map<String, dynamic>;

      setState(() {
        if (data['type'] != null && _types.contains(data['type'])) {
          _type = data['type'];
        }
        if (data['policy_number'] != null) _policyNrCtrl.text = data['policy_number'];
        if (data['insurer_company'] != null) {
          // gasim cel mai apropiat din lista
          final found = _insurers.firstWhere(
            (i) => i.toLowerCase() == (data['insurer_company'] as String).toLowerCase(),
            orElse: () => 'Altul',
          );
          _insurerCtrl.text = found;
        }
        if (data['premium_amount'] != null) _premiumCtrl.text = '${data['premium_amount']}';
        if (data['valid_from'] != null) _validFrom = DateTime.parse(data['valid_from']);
        if (data['valid_until'] != null) _validUntil = DateTime.parse(data['valid_until']);
      });

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scanare completă! Verificați datele.'),
            backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scanare eșuată: $e'), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (_isEditing) {
        await CarService().updateInsurance(widget.carId, widget.existing!.id, {
          'type': _type,
          'insurer_company': _insurerCtrl.text.trim(),
          'purchase_date': _purchaseDate.toIso8601String().substring(0, 10),
          'valid_from': _validFrom.toIso8601String().substring(0, 10),
          'valid_until': _validUntil.toIso8601String().substring(0, 10),
          'payment_frequency': _frequency,
          'roadside_assistance': _roadsideAssistance,
          if (_policyNrCtrl.text.isNotEmpty) 'policy_number': _policyNrCtrl.text,
          if (_agentNameCtrl.text.isNotEmpty) 'agent_name': _agentNameCtrl.text,
          if (_agentPhoneCtrl.text.isNotEmpty) 'agent_phone': _agentPhoneCtrl.text,
          if (_premiumCtrl.text.isNotEmpty) 'premium_amount': double.parse(_premiumCtrl.text),
          if (_deductibleCtrl.text.isNotEmpty) 'deductible_amount': double.parse(_deductibleCtrl.text),
          if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text,
        });
      } else {
      await CarService().createInsurance(widget.carId, {
        'type': _type,
        'insurer_company': _insurerCtrl.text.trim(),
        'purchase_date': _purchaseDate.toIso8601String().substring(0, 10),
        'valid_from': _validFrom.toIso8601String().substring(0, 10),
        'valid_until': _validUntil.toIso8601String().substring(0, 10),
        'payment_frequency': _frequency,
        'roadside_assistance': _roadsideAssistance,
        if (_policyNrCtrl.text.isNotEmpty) 'policy_number': _policyNrCtrl.text,
        if (_agentNameCtrl.text.isNotEmpty) 'agent_name': _agentNameCtrl.text,
        if (_agentPhoneCtrl.text.isNotEmpty) 'agent_phone': _agentPhoneCtrl.text,
        if (_premiumCtrl.text.isNotEmpty) 'premium_amount': double.parse(_premiumCtrl.text),
        if (_deductibleCtrl.text.isNotEmpty) 'deductible_amount': double.parse(_deductibleCtrl.text),
        if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text,
      });
      } // end else
      if (mounted) {
        ref.invalidate(insuranceFutureProvider(widget.carId));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_isEditing ? 'Asigurare actualizată!' : 'Asigurare adăugată!'),
            backgroundColor: AppColors.success));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Eroare: $e'), backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _datePicker(String label, DateTime date, ValueChanged<DateTime> onPick) =>
      InkWell(
        onTap: () async {
          final d = await showDatePicker(
              context: context, initialDate: date,
              firstDate: DateTime(2000), lastDate: DateTime(2035));
          if (d != null) onPick(d);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true, fillColor: Colors.white,
          ),
          child: Text(_fmt.format(date),
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editează $_type' : 'Adaugă $_type')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Scanare OCR
            ScanCard(
              scannedImage: _scannedImage,
              isScanning: _isScanning,
              onScan: _scan,
            ),
            const SizedBox(height: 16),
            // Tip asigurare
            Row(
              children: _types.map((t) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(t),
                  selected: _type == t,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _type == t ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _type = t),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            // Firma asiguratoare
            DropdownButtonFormField<String>(
              value: _insurerCtrl.text.isEmpty ? null : _insurers.contains(_insurerCtrl.text) ? _insurerCtrl.text : null,
              decoration: InputDecoration(
                labelText: 'Firma asigurătoare *',
                prefixIcon: const Icon(Icons.business_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.white,
              ),
              items: _insurers.map((i) =>
                  DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: (v) => setState(() => _insurerCtrl.text = v ?? ''),
              validator: (_) => _insurerCtrl.text.isEmpty ? 'Obligatoriu' : null,
            ),
            const SizedBox(height: 14),
            CmTextField(controller: _policyNrCtrl, label: 'Nr. poliță',
                hint: 'RCA-2026-XXXXX', prefixIcon: Icons.confirmation_number_outlined),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _datePicker('Cumpărată la', _purchaseDate,
                  (d) => setState(() => _purchaseDate = d))),
              const SizedBox(width: 12),
              Expanded(child: _datePicker('Valabilă de la', _validFrom,
                  (d) => setState(() => _validFrom = d))),
            ]),
            const SizedBox(height: 12),
            _datePicker('Expiră la', _validUntil,
                (d) => setState(() => _validUntil = d)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: CmTextField(
                  controller: _premiumCtrl, label: 'Primă (RON)',
                  hint: '650', keyboardType: TextInputType.number,
                  prefixIcon: Icons.payments_outlined)),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<String>(
                value: _frequency,
                decoration: InputDecoration(
                  labelText: 'Frecvență plată',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true, fillColor: Colors.white,
                ),
                items: _frequencies.entries.map((e) =>
                    DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: (v) => setState(() => _frequency = v!),
              )),
            ]),
            const SizedBox(height: 14),
            CmTextField(controller: _deductibleCtrl, label: 'Franciză (RON)',
                hint: '500', keyboardType: TextInputType.number,
                prefixIcon: Icons.money_off_outlined),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: CmTextField(
                  controller: _agentNameCtrl, label: 'Numele agentului',
                  hint: 'Ion Popescu', prefixIcon: Icons.person_outline)),
              const SizedBox(width: 12),
              Expanded(child: CmTextField(
                  controller: _agentPhoneCtrl, label: 'Telefon agent',
                  hint: '07XX XXX XXX', keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined)),
            ]),
            const SizedBox(height: 14),
            SwitchListTile(
              value: _roadsideAssistance,
              onChanged: (v) => setState(() => _roadsideAssistance = v),
              title: const Text('Asistență rutieră inclusă'),
              secondary: const Icon(Icons.car_repair, color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border)),
              tileColor: Colors.white,
            ),
            const SizedBox(height: 14),
            CmTextField(controller: _notesCtrl, label: 'Note', hint: 'Observații...',
                maxLines: 2, prefixIcon: Icons.notes),
            const SizedBox(height: 28),
            CmButton(label: 'Salvează asigurarea', icon: Icons.save,
                isLoading: _isLoading, onPressed: _isLoading ? null : _save),
          ],
        ),
      ),
    );
  }
}
