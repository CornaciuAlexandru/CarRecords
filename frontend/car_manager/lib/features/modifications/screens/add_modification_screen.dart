import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/documents.dart';
import '../../../core/services/car_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/cm_text_field.dart';
import '../../../shared/widgets/cm_button.dart';
import 'modifications_screen.dart';

class AddModificationScreen extends ConsumerStatefulWidget {
  final String carId;
  final CarModification? existing;
  const AddModificationScreen({super.key, required this.carId, this.existing});

  @override
  ConsumerState<AddModificationScreen> createState() => _AddModificationScreenState();
}

class _AddModificationScreenState extends ConsumerState<AddModificationScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _descCtrl    = TextEditingController();
  final _byCtrl      = TextEditingController();
  final _costCtrl    = TextEditingController();
  final _homoNrCtrl  = TextEditingController();
  final _notesCtrl   = TextEditingController();

  late String _category;
  DateTime? _date;
  late bool _isHomologated;
  bool _isLoading = false;

  bool get _isEditing => widget.existing != null;

  static const _categories = {
    'motor': 'Motor', 'exterior': 'Exterior', 'interior': 'Interior',
    'suspensie': 'Suspensie', 'audio': 'Audio', 'electronic': 'Electronic',
    'frane': 'Frâne', 'altul': 'Altul',
  };

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _category = e?.category ?? 'exterior';
    _date = e?.modificationDate;
    _isHomologated = e?.isHomologated ?? false;
    if (e != null) {
      _descCtrl.text   = e.description;
      _byCtrl.text     = e.performedBy ?? '';
      _costCtrl.text   = e.cost != null ? '${e.cost}' : '';
      _homoNrCtrl.text = e.homologationNumber ?? '';
      _notesCtrl.text  = e.notes ?? '';
    }
  }

  Map<String, dynamic> _buildPayload() => {
    'category': _category,
    'description': _descCtrl.text.trim(),
    if (_date != null) 'modification_date': _date!.toIso8601String().substring(0, 10),
    if (_byCtrl.text.isNotEmpty) 'performed_by': _byCtrl.text.trim(),
    if (_costCtrl.text.isNotEmpty) 'cost': double.parse(_costCtrl.text),
    'is_homologated': _isHomologated,
    if (_homoNrCtrl.text.isNotEmpty) 'homologation_number': _homoNrCtrl.text.trim(),
    if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text.trim(),
  };

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (_isEditing) {
        await CarService().updateModification(widget.carId, widget.existing!.id, _buildPayload());
      } else {
        await CarService().createModification(widget.carId, _buildPayload());
      }
      if (mounted) {
        ref.invalidate(modificationsFutureProvider(widget.carId));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Modificare actualizată!' : 'Modificare adăugată!'),
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
      appBar: AppBar(title: Text(_isEditing ? 'Editează modificare' : 'Adaugă modificare')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Categorie *', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _categories.entries.map((e) => ChoiceChip(
                label: Text(e.value),
                selected: _category == e.key,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: _category == e.key ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600),
                onSelected: (_) => setState(() => _category = e.key),
              )).toList(),
            ),
            const SizedBox(height: 16),
            CmTextField(
              controller: _descCtrl, label: 'Descriere modificare *',
              hint: 'Ex: Instalare suspensie sport KW V3',
              maxLines: 2, prefixIcon: Icons.description_outlined,
              validator: (v) => (v == null || v.isEmpty) ? 'Obligatoriu' : null,
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(context: context,
                    initialDate: _date ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());
                if (d != null) setState(() => _date = d);
              },
              child: InputDecorator(
                decoration: InputDecoration(labelText: 'Data modificării (opțional)', prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
                child: Text(_date != null ? fmt.format(_date!) : 'Alege dată',
                    style: TextStyle(fontWeight: FontWeight.w500, color: _date != null ? null : AppColors.textSecondary)),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: CmTextField(controller: _byCtrl, label: 'Realizată de', hint: 'Service / Persoană', prefixIcon: Icons.build_outlined)),
              const SizedBox(width: 12),
              Expanded(child: CmTextField(controller: _costCtrl, label: 'Cost (RON)', hint: '1500', keyboardType: TextInputType.number, prefixIcon: Icons.payments_outlined)),
            ]),
            const SizedBox(height: 14),
            SwitchListTile(
              value: _isHomologated,
              onChanged: (v) => setState(() => _isHomologated = v),
              title: const Text('Modificare omologată RAR'),
              secondary: const Icon(Icons.verified_outlined, color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
              tileColor: Colors.white,
            ),
            if (_isHomologated) ...[
              const SizedBox(height: 14),
              CmTextField(controller: _homoNrCtrl, label: 'Nr. omologare', hint: 'RAR-XXXX-2026', prefixIcon: Icons.numbers),
            ],
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
