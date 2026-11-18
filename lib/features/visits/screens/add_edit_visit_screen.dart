import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../models/visit.dart';
import '../../../providers/doctor_provider.dart';
import '../../../providers/visit_provider.dart';

class AddEditVisitScreen extends StatefulWidget {
  final Visit? visit;
  final int? preselectedDoctorId;

  const AddEditVisitScreen({
    super.key,
    this.visit,
    this.preselectedDoctorId,
  });

  @override
  State<AddEditVisitScreen> createState() => _AddEditVisitScreenState();
}

class _AddEditVisitScreenState extends State<AddEditVisitScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _dateController;
  late TextEditingController _reasonController;
  late TextEditingController _diagnosisController;
  late TextEditingController _notesController;

  int? _selectedDoctorId;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final v = widget.visit;
    _dateController = TextEditingController(
      text: v != null && v.visitDate.isNotEmpty
          ? v.visitDate
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _reasonController = TextEditingController(text: v?.reason ?? '');
    _diagnosisController = TextEditingController(text: v?.diagnosis ?? '');
    _notesController = TextEditingController(text: v?.notes ?? '');

    if (v != null) {
      _selectedDoctorId = v.doctorId;
      try {
        _selectedDate = DateTime.parse(v.visitDate);
      } catch (_) {}
    } else {
      _selectedDoctorId = widget.preselectedDoctorId;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _reasonController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveVisit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<VisitProvider>();

    final now = DateTime.now().toIso8601String();
    final visit = Visit(
      id: widget.visit?.id,
      doctorId: _selectedDoctorId,
      visitDate: _dateController.text.trim(),
      reason: _reasonController.text.trim(),
      diagnosis:
          _diagnosisController.text.trim().isEmpty ? null : _diagnosisController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.visit?.createdAt ?? now,
    );

    final isEditing = widget.visit != null;
    final success =
        isEditing ? await provider.updateVisit(visit) : await provider.createVisit(visit);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Visit updated successfully.' : 'Consultation logged successfully.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to save visit.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.visit != null;
    final doctors = context.watch<DoctorProvider>().doctors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Consultation' : 'Log Consultation',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveVisit,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date
              CustomTextField(
                controller: _dateController,
                label: 'Consultation Date',
                hint: 'YYYY-MM-DD',
                prefixIcon: Icons.calendar_today_rounded,
                requiredField: true,
                readOnly: true,
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),

              // Doctor selector
              const Text(
                'Attending Physician (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int?>(
                initialValue: _selectedDoctorId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                hint: const Text('None / External Doctor'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('None / External Doctor'),
                  ),
                  ...doctors.map((doc) {
                    return DropdownMenuItem<int?>(
                      value: doc.id,
                      child: Text(
                        '${doc.fullName} (${doc.specialty})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: (val) {
                  setState(() => _selectedDoctorId = val);
                },
              ),
              const SizedBox(height: 16),

              // Reason
              CustomTextField(
                controller: _reasonController,
                label: 'Reason for Consultation',
                hint: 'e.g. Annual physical exam, chest pain, recurring fever',
                prefixIcon: Icons.help_outline_rounded,
                requiredField: true,
                textCapitalization: TextCapitalization.sentences,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter reason for consultation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Diagnosis
              CustomTextField(
                controller: _diagnosisController,
                label: 'Doctor Diagnosis (Optional)',
                hint: 'e.g. Stage 1 Hypertension, Acute Pharyngitis',
                prefixIcon: Icons.medical_services_outlined,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Notes / Instructions
              CustomTextField(
                controller: _notesController,
                label: 'Clinical Notes & Treatment Plan',
                hint: 'Prescribed medications, dietary advice, follow-up dates...',
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveVisit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          isEditing ? 'Update Consultation' : 'Save Consultation Record',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
