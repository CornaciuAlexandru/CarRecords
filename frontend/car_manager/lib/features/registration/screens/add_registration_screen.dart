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
import 'registration_screen.dart';

class AddRegistrationScreen extends ConsumerStatefulWidget {
  final String carId;
  final VehicleRegistration? existing;
  const AddRegistrationScreen({super.key, required this.carId, this.existing});

  @override
  ConsumerState<AddRegistrationScreen> createState() => _AddRegistrationScreenState();
}

class _AddRegistrationScreenState extends ConsumerState<AddRegistrationScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _fmt          = DateFormat('dd.MM.yyyy');
  final _regNrCtrl    = TextEditingController();
  final _ownerCtrl    = TextEditingController();
  final _addressCtrl  = TextEditingController();
  final _seriesCtrl   = TextEditingController();
  final _brandCtrl    = TextEditingController();
  final _modelCtrl    = TextEditingController();
  final _yearCtrl     = TextEditingController();
  final _notesCtrl    = TextEditingController();

  DateTime? _registrationDate;
  DateTime? _itpExpiry;
  bool _isLoading  = false;
  bool _isScanning = false;
  File? _scannedImage;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _regNrCtrl.text   = e.registrationNumber ?? '';
      _ownerCtrl.text   = e.ownerName ?? '';
      _addressCtrl.text = e.ownerAddress ?? '';
      _seriesCtrl.text  = e.carSeries ?? '';
      _brandCtrl.text   = e.brand ?? '';
      _modelCtrl.text   = e.model ?? '';
      _yearCtrl.text    = e.manufacturingYear ?? '';
      _notesCtrl.text   = e.notes ?? '';
      _registrationDate = e.registrationDate;
      _itpExpiry        = e.itpExpiryDate;
    }
  }

  @override
  void dispose() {
    _regNrCtrl.dispose(); _ownerCtrl.dispose(); _addressCtrl.dispose();
    _seriesCtrl.dispose(); _brandCtrl.dispose(); _modelCtrl.dispose();
    _yearCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _scan(String filePath) async {
    setState(() { _scannedImage = File(filePath); _isScanning = true; });
    try {
      final result = await CarService().scanRegistration(widget.carId, filePath);
      final data = result['extracted_data'] as Map<String, dynamic>;
      _applyOcrData(data);
      if (mounted) _showQuickSaveDialog(data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scanare eșuată: $e'), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _applyOcrData(Map<String, dynamic> data) {
    setState(() {
      if (data['owner_name']        != null) _ownerCtrl.text  = data['owner_name'];
      if (data['car_series']        != null) _seriesCtrl.text = data['car_series'];
      if (data['brand']             != null) _brandCtrl.text  = data['brand'];
      if (data['model']             != null) _modelCtrl.text  = data['model'];
      if (data['manufacturing_year'] != null) _yearCtrl.text  = data['manufacturing_year'];
      if (data['registration_number'] != null) _regNrCtrl.text = data['registration_number'];
      if (data['itp_expiry_date']   != null) _itpExpiry = DateTime.parse(data['itp_expiry_date']);
      if (data['registration_date'] != null) _registrationDate = DateTime.parse(data['registration_date']);
    });
  }

  void _showQuickSaveDialog(Map<String, dynamic> data) {
    final hasData = data['owner_name'] != null || data['itp_expiry_date'] != null ||
        data['registration_date'] != null || data['brand'] != null ||
        data['car_series'] != null || data['manufacturing_year'] != null;
    final rawText = data['ocr_raw_text'] as String? ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.document_scanner, color: AppColors.primary),
          SizedBox(width: 8), Text('Date extrase din talon'),
        ]),
        content: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            if (hasData) ...[
              const Text('Câmpurile au fost completate automat. Salvezi direct sau verifici mai întâi?',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),
              if (data['registration_number'] != null) _ocrRow('Nr. înmatriculare', data['registration_number']),
              if (data['brand']             != null) _ocrRow('Marcă', data['brand']),
              if (data['model']             != null) _ocrRow('Model', data['model']),
              if (data['manufacturing_year'] != null) _ocrRow('An fabricație', data['manufacturing_year']),
              if (data['car_series']        != null) _ocrRow('Serie șasiu (VIN)', data['car_series']),
              if (data['owner_name']        != null) _ocrRow('Proprietar', data['owner_name']),
              if (data['registration_date'] != null) _ocrRow('Data înmatriculării', data['registration_date']),
              if (data['itp_expiry_date']   != null) _ocrRow('ITP expiră', data['itp_expiry_date']),
            ] else ...[
              const Icon(Icons.info_outline, color: AppColors.warning, size: 32),
              const SizedBox(height: 8),
              const Text('Nu s-au putut extrage date automat.', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text('Completați câmpurile manual. Sfaturi:\n• Iluminare bună\n• Document drept, fără umbre\n• Imagine clară',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              if (rawText.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text('Text detectat:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                  child: Text(rawText, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
                ),
              ],
            ],
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Verifică mai întâi')),
          ElevatedButton.icon(
            icon: const Icon(Icons.save, size: 18), label: const Text('Salvează direct'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () { Navigator.pop(context); _save(); },
          ),
        ],
      ),
    );
  }

  Widget _ocrRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
    ]),
  );

  Map<String, dynamic> _buildPayload() => {
    if (_regNrCtrl.text.isNotEmpty)   'registration_number': _regNrCtrl.text.trim(),
    if (_registrationDate != null)    'registration_date': _registrationDate!.toIso8601String().substring(0, 10),
    if (_itpExpiry != null)           'itp_expiry_date': _itpExpiry!.toIso8601String().substring(0, 10),
    if (_ownerCtrl.text.isNotEmpty)   'owner_name': _ownerCtrl.text.trim(),
    if (_addressCtrl.text.isNotEmpty) 'owner_address': _addressCtrl.text.trim(),
    if (_seriesCtrl.text.isNotEmpty)  'car_series': _seriesCtrl.text.trim(),
    if (_brandCtrl.text.isNotEmpty)   'brand': _brandCtrl.text.trim(),
    if (_modelCtrl.text.isNotEmpty)   'model': _modelCtrl.text.trim(),
    if (_yearCtrl.text.isNotEmpty)    'manufacturing_year': _yearCtrl.text.trim(),
    if (_notesCtrl.text.isNotEmpty)   'notes': _notesCtrl.text.trim(),
  };

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (_isEditing) {
        await CarService().updateRegistration(widget.carId, widget.existing!.id, _buildPayload());
      } else {
        await CarService().createRegistration(widget.carId, _buildPayload());
      }
      if (mounted) {
        ref.invalidate(registrationFutureProvider(widget.carId));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Talon actualizat!' : 'Talon adăugat!'),
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

  Widget _datePicker(String label, DateTime? date, ValueChanged<DateTime> onPick) =>
      InkWell(
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(1990),
            lastDate: DateTime(2040),
          );
          if (d != null) onPick(d);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          child: Text(
            date != null ? _fmt.format(date) : 'Alege dată',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: date != null ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      );

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 4),
    child: Row(children: [
      Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editează talon' : 'Adaugă Talon / ITP')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ScanCard(scannedImage: _scannedImage, isScanning: _isScanning, onScan: _scan),
            const SizedBox(height: 20),

            // ── Date vehicul ──────────────────────────────────────
            _sectionTitle('Date vehicul'),
            Row(children: [
              Expanded(child: CmTextField(controller: _brandCtrl, label: 'Marcă', hint: 'DACIA', prefixIcon: Icons.directions_car_outlined)),
              const SizedBox(width: 12),
              Expanded(child: CmTextField(controller: _modelCtrl, label: 'Model', hint: 'Logan')),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: CmTextField(controller: _yearCtrl, label: 'An fabricație', hint: '2018',
                  keyboardType: TextInputType.number, prefixIcon: Icons.factory_outlined)),
              const SizedBox(width: 12),
              Expanded(child: CmTextField(controller: _regNrCtrl, label: 'Nr. înmatriculare', hint: 'B123XXX',
                  prefixIcon: Icons.confirmation_number_outlined)),
            ]),
            const SizedBox(height: 14),
            CmTextField(controller: _seriesCtrl, label: 'Serie șasiu (VIN)', hint: 'UU1LSDAXXXXXXXXXX',
                prefixIcon: Icons.pin_outlined),
            const SizedBox(height: 20),

            // ── Date inmatriculare / ITP ──────────────────────────
            _sectionTitle('Înmatriculare & ITP'),
            _datePicker('Data înmatriculării', _registrationDate, (d) => setState(() => _registrationDate = d)),
            const SizedBox(height: 14),
            _datePicker('Data expirare ITP', _itpExpiry, (d) => setState(() => _itpExpiry = d)),
            if (_itpExpiry != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _itpExpiry!.isBefore(DateTime.now())
                      ? AppColors.danger.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _itpExpiry!.isBefore(DateTime.now())
                        ? AppColors.danger.withOpacity(0.4)
                        : AppColors.success.withOpacity(0.4),
                  ),
                ),
                child: Row(children: [
                  Icon(
                    _itpExpiry!.isBefore(DateTime.now()) ? Icons.error_outline : Icons.check_circle_outline,
                    size: 18,
                    color: _itpExpiry!.isBefore(DateTime.now()) ? AppColors.danger : AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _itpExpiry!.isBefore(DateTime.now()) ? 'ITP expirat!' : 'ITP valabil',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _itpExpiry!.isBefore(DateTime.now()) ? AppColors.danger : AppColors.success,
                    ),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 20),

            // ── Proprietar ────────────────────────────────────────
            _sectionTitle('Proprietar'),
            CmTextField(controller: _ownerCtrl, label: 'Nume proprietar', hint: 'Ion Popescu', prefixIcon: Icons.person_outline),
            const SizedBox(height: 14),
            CmTextField(controller: _addressCtrl, label: 'Adresă proprietar', hint: 'Str. Exemplu, nr. 1, București',
                prefixIcon: Icons.home_outlined, maxLines: 2),
            const SizedBox(height: 14),
            CmTextField(controller: _notesCtrl, label: 'Note', hint: 'Observații...', maxLines: 2, prefixIcon: Icons.notes),
            const SizedBox(height: 28),
            CmButton(
              label: _isEditing ? 'Actualizează' : 'Salvează',
              icon: Icons.save,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
