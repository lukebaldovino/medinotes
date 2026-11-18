import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../models/patient.dart';
import '../../../providers/patient_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final Patient? patient;

  const EditProfileScreen({super.key, this.patient});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _contactController;
  late TextEditingController _emergencyController;
  late TextEditingController _allergiesController;

  String _selectedSex = 'Male';
  String? _selectedBloodType;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _nameController = TextEditingController(text: p?.fullName ?? '');
    _dobController = TextEditingController(text: p?.birthDate ?? '');
    _contactController = TextEditingController(text: p?.contactNumber ?? '');
    _emergencyController = TextEditingController(text: p?.emergencyContact ?? '');
    _allergiesController = TextEditingController(text: p?.allergies ?? '');

    if (p != null) {
      if (AppConstants.sexOptions.contains(p.sex)) {
        _selectedSex = p.sex;
      }
      _selectedBloodType = p.bloodType;
      if (p.birthDate.isNotEmpty) {
        try {
          _selectedDate = DateTime.parse(p.birthDate);
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _contactController.dispose();
    _emergencyController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDate ?? DateTime(now.year - 25, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now().toIso8601String();
    final patient = Patient(
      id: widget.patient?.id,
      fullName: _nameController.text.trim(),
      birthDate: _dobController.text.trim(),
      sex: _selectedSex,
      bloodType: _selectedBloodType,
      contactNumber: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
      emergencyContact: _emergencyController.text.trim().isEmpty ? null : _emergencyController.text.trim(),
      allergies: _allergiesController.text.trim().isEmpty ? null : _allergiesController.text.trim(),
      createdAt: widget.patient?.createdAt ?? now,
      updatedAt: now,
    );

    final provider = context.read<PatientProvider>();
    final success = await provider.saveProfile(patient);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient profile saved successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to save profile.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.patient != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Profile' : 'Create Profile',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
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
              // Basic Information Section
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'e.g. Maria Clara De Los Santos',
                prefixIcon: Icons.person_outline_rounded,
                requiredField: true,
                textCapitalization: TextCapitalization.words,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter patient full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _dobController,
                label: 'Date of Birth',
                hint: 'YYYY-MM-DD',
                prefixIcon: Icons.calendar_today_rounded,
                requiredField: true,
                readOnly: true,
                onTap: _pickDate,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please select date of birth';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Sex Dropdown
              const Text(
                'Sex *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedSex,
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
                items: AppConstants.sexOptions.map((sex) {
                  return DropdownMenuItem(value: sex, child: Text(sex));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSex = val);
                },
              ),
              const SizedBox(height: 24),

              // Medical Details Section
              const Text(
                'Medical Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              // Blood Type Dropdown
              const Text(
                'Blood Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedBloodType,
                hint: const Text('Select Blood Type (Optional)'),
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
                items: AppConstants.bloodTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedBloodType = val);
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _allergiesController,
                label: 'Allergies',
                hint: 'e.g. Penicillin, Peanuts, Aspirin, Latex (or None)',
                prefixIcon: Icons.warning_amber_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Contact & Emergency Section
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _contactController,
                label: 'Contact Number',
                hint: 'e.g. +63 917 123 4567',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emergencyController,
                label: 'Emergency Contact Person & Phone',
                hint: 'e.g. Juan Cruz (Spouse) - +63 918 765 4321',
                prefixIcon: Icons.emergency_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Consumer<PatientProvider>(
                  builder: (context, provider, child) {
                    return ElevatedButton(
                      onPressed: provider.isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              isEditing ? 'Update Profile' : 'Save Profile',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    );
                  },
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
