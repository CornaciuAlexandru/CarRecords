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
import 'vignettes_screen.dart';
import '../../../core/utils/l10n.dart';
import '../../../core/services/ads_service.dart';

class AddVignetteScreen extends ConsumerStatefulWidget {
  final String carId;
  final Vignette? existing;
  const AddVignetteScreen({super.key, required this.carId, this.existing});

  @override
  ConsumerState<AddVignetteScreen> createState() => _AddVignetteScreenState();
}

class _AddVignetteScreenState extends ConsumerState<AddVignetteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fmt = DateFormat('dd.MM.yyyy');
  final _service = CarService();

  final _companyCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _invoiceNrCtrl = TextEditingController();
  final _invoiceSeriesCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late DateTime _purchaseDate;
  late DateTime _validFrom;
  DateTime? _validUntil;
  late String _period;
  bool _isLoading = false;
  bool _isScanning = false;
  File? _scannedImage;

  bool get _isEditing => widget.existing != null;

  static const _periods = {'7_zile': '7 zile', '30_zile': '30 zile', '90_zile': '90 zile', '1_an': '1 an'};

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _purchaseDate = e?.purchaseDate ?? DateTime.now();
    _validFrom    = e?.validFrom   ?? DateTime.now();
    _period       = e?.validityPeriod ?? '1_an';
    _validUntil   = e?.validUntil;
    if (e != null) {
      _companyCtrl.text      = e.issuerCompany ?? '';
      _cityCtrl.text         = e.city ?? '';
      _priceCtrl.text        = e.price != null ? '${e.price}' : '';
      _invoiceNrCtrl.text    = e.invoiceNumber ?? '';
      _invoiceSeriesCtrl.text = e.invoiceSeries ?? '';
      _notesCtrl.text        = e.notes ?? '';
    } else {
      _updateUntilDate();
    }
  }

  void _updateUntilDate() {
    final days = {'7_zile': 7, '30_zile': 30, '90_zile': 90, '1_an': 365};
    setState(() => _validUntil = _validFrom.add(Duration(days: days[_period] ?? 365)));
  }

  Map<String, dynamic> _buildPayload() => {
    'purchase_date': _purchaseDate.toIso8601String().substring(0, 10),
    'valid_from':    _validFrom.toIso8601String().substring(0, 10),
    'valid_until':   _validUntil!.toIso8601String().substring(0, 10),
    'validity_period': _period,
    if (_companyCtrl.text.isNotEmpty) 'issuer_company': _companyCtrl.text,
    if (_cityCtrl.text.isNotEmpty) 'city': _cityCtrl.text,
    if (_priceCtrl.text.isNotEmpty) 'price': double.tryParse(_priceCtrl.text),
    if (_invoiceNrCtrl.text.isNotEmpty) 'invoice_number': _invoiceNrCtrl.text,
    if (_invoiceSeriesCtrl.text.isNotEmpty) 'invoice_series': _invoiceSeriesCtrl.text,
    if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text,
  };

  Future<void> _scan(String filePath) async {
    setState(() { _scannedImage = File(filePath); _isScanning = true; });
    try {
      final result = await _service.scanVignette(widget.carId, filePath);
      final data = result['extracted_data'] as Map<String, dynamic>;
      _applyOcrData(data);
      if (mounted) _showQuickSaveDialog(data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context).scanFailed('$e')), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _applyOcrData(Map<String, dynamic> data) {
    setState(() {
      if (data['issuer_company'] != null) _companyCtrl.text = data['issuer_company'];
      if (data['city'] != null) _cityCtrl.text = data['city'];
      if (data['price'] != null) _priceCtrl.text = '${data['price']}';
      if (data['invoice_number'] != null) _invoiceNrCtrl.text = data['invoice_number'];
      if (data['validity_period'] != null) { _period = data['validity_period']; _updateUntilDate(); }
      if (data['valid_from'] != null) { _validFrom = DateTime.parse(data['valid_from']); _updateUntilDate(); }
    });
  }

  void _showQuickSaveDialog(Map<String, dynamic> data) {
    final hasData = data['issuer_company'] != null || data['validity_period'] != null ||
        data['valid_from'] != null || data['price'] != null;
    final rawText = data['ocr_raw_text'] as String? ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(children: [
          Icon(Icons.document_scanner, color: AppColors.primary),
          SizedBox(width: 8), Text(tr(context).extractedData),
        ]),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasData) ...[
                Text(tr(context).fieldsAutoFilled,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 12),
                if (data['issuer_company'] != null) _ocrRow(tr(context).issuer, data['issuer_company']),
                if (data['validity_period'] != null) _ocrRow(tr(context).period, _periods[data['validity_period']] ?? data['validity_period']),
                if (data['valid_from'] != null) _ocrRow(tr(context).validFrom, data['valid_from']),
                if (data['price'] != null) _ocrRow(tr(context).price, '${data['price']} RON'),
              ] else ...[
                const Icon(Icons.info_outline, color: AppColors.warning, size: 32),
                const SizedBox(height: 8),
                Text(tr(context).noDataExtracted,
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const Text('Completați câmpurile manual. Sfaturi pentru o scanare mai bună:\n• Iluminare bună\n• Document drept, fără umbre\n• Imagine clară, nedistorsionată',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                if (rawText.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(tr(context).detectedText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                    child: Text(rawText, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
                  ),
                ],
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr(context).checkFirst),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save, size: 18),
            label: Text(tr(context).saveDirectly),
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
      Text(value, style: const TextStyle(fontSize: 13)),
    ]),
  );

  Future<void> _save() async {
    if (_validUntil == null) return;
    setState(() => _isLoading = true);
    try {
      if (_isEditing) {
        await _service.updateVignette(widget.carId, widget.existing!.id, _buildPayload());
      } else {
        await _service.createVignette(widget.carId, _buildPayload());
      }
      if (mounted) {
        ref.invalidate(vignettesFutureProvider(widget.carId));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? tr(context).vignetteUpdated : tr(context).vignetteAdded),
          backgroundColor: AppColors.success,
        ));
        context.pop();
        // Ocazional, o reclama pe tot ecranul (nu la fiecare salvare)
        AdsService.instance.onUserAction();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context).errorWith('$e')), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? tr(context).editVignette : tr(context).addVignette)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ScanCard(scannedImage: _scannedImage, isScanning: _isScanning, onScan: _scan),
            const SizedBox(height: 20),
            Text(tr(context).validityPeriod, style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _periods.entries.map((e) => ChoiceChip(
                label: Text(e.value),
                selected: _period == e.key,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: _period == e.key ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600),
                onSelected: (_) => setState(() { _period = e.key; _updateUntilDate(); }),
              )).toList(),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _DateField(label: tr(context).purchaseDate, date: _purchaseDate,
                  onPick: (d) => setState(() => _purchaseDate = d))),
              const SizedBox(width: 12),
              Expanded(child: _DateField(label: tr(context).validFrom, date: _validFrom,
                  onPick: (d) { setState(() => _validFrom = d); _updateUntilDate(); })),
            ]),
            if (_validUntil != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Text(tr(context).expiresOnDate(_fmt.format(_validUntil!)),
                      style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                ]),
              ),
            ],
            const SizedBox(height: 20),
            CmTextField(controller: _companyCtrl, label: tr(context).issuerCompany, hint: 'CNAIR', prefixIcon: Icons.business_outlined),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: CmTextField(controller: _cityCtrl, label: tr(context).city, hint: tr(context).hintCity, prefixIcon: Icons.location_city_outlined)),
              const SizedBox(width: 12),
              Expanded(child: CmTextField(controller: _priceCtrl, label: tr(context).priceRon, hint: '28.50', keyboardType: TextInputType.number, prefixIcon: Icons.payments_outlined)),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: CmTextField(controller: _invoiceSeriesCtrl, label: tr(context).invoiceSeries, hint: 'RO')),
              const SizedBox(width: 12),
              Expanded(child: CmTextField(controller: _invoiceNrCtrl, label: tr(context).invoiceNr, hint: '1234567', keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 14),
            CmTextField(controller: _notesCtrl, label: tr(context).notes, hint: tr(context).notesHint, maxLines: 2, prefixIcon: Icons.notes),
            const SizedBox(height: 28),
            CmButton(label: _isEditing ? tr(context).update : tr(context).saveVignette, icon: Icons.save,
                isLoading: _isLoading, onPressed: _isLoading ? null : _save),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label; final DateTime date; final ValueChanged<DateTime> onPick;
  const _DateField({required this.label, required this.date, required this.onPick});
  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy');
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2030));
        if (picked != null) onPick(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.calendar_today_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
        child: Text(fmt.format(date), style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }
}
