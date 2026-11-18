import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/storage/file_storage_service.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../models/medical_record.dart';
import '../../../providers/record_provider.dart';
import '../widgets/attachment_preview_card.dart';

class AddEditRecordScreen extends StatefulWidget {
  final MedicalRecord? record;

  const AddEditRecordScreen({super.key, this.record});

  @override
  State<AddEditRecordScreen> createState() => _AddEditRecordScreenState();
}

class _AddEditRecordScreenState extends State<AddEditRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _dateController;
  late TextEditingController _doctorController;
  late TextEditingController _facilityController;
  late TextEditingController _descriptionController;

  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  // Attachment state
  File? _newPickedFile;
  String? _newPickedFileName;
  String? _newPickedFileType; // 'pdf' or 'image'

  String? _existingFilePath;
  String? _existingFileType;
  bool _removedExistingAttachment = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _titleController = TextEditingController(text: r?.title ?? '');
    _dateController = TextEditingController(
      text: r != null && r.recordDate.isNotEmpty
          ? r.recordDate
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _doctorController = TextEditingController(text: r?.doctorName ?? '');
    _facilityController = TextEditingController(text: r?.facilityName ?? '');
    _descriptionController = TextEditingController(text: r?.description ?? '');

    if (r != null) {
      _selectedCategoryId = r.categoryId;
      _existingFilePath = r.filePath;
      _existingFileType = r.fileType;
      try {
        _selectedDate = DateTime.parse(r.recordDate);
      } catch (_) {}
    } else {
      // Default category id 1
      _selectedCategoryId = 1;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _doctorController.dispose();
    _facilityController.dispose();
    _descriptionController.dispose();
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

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final file = File(path);
        if (await file.exists()) {
          setState(() {
            _newPickedFile = file;
            _newPickedFileName = result.files.single.name;
            _newPickedFileType = 'pdf';
            _removedExistingAttachment = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (picked != null) {
        final file = File(picked.path);
        setState(() {
          _newPickedFile = file;
          _newPickedFileName = p.basename(picked.path);
          _newPickedFileType = 'image';
          _removedExistingAttachment = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: const Text('Photo Gallery'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: const Text('Take Photo with Camera'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeAttachment() {
    setState(() {
      _newPickedFile = null;
      _newPickedFileName = null;
      _newPickedFileType = null;
      _removedExistingAttachment = true;
    });
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a record category.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? finalFilePath = _existingFilePath;
      String? finalFileType = _existingFileType;

      if (_removedExistingAttachment) {
        finalFilePath = null;
        finalFileType = null;
      }

      final provider = context.read<RecordProvider>();

      // If user selected a new file, copy it into managed app storage
      if (_newPickedFile != null && _newPickedFileName != null) {
        final relativePath = await FileStorageService.instance.saveDocumentFile(
          sourceFile: _newPickedFile!,
          originalFileName: _newPickedFileName!,
        );
        finalFilePath = relativePath;
        finalFileType = _newPickedFileType;
      }

      final now = DateTime.now().toIso8601String();
      final record = MedicalRecord(
        id: widget.record?.id,
        title: _titleController.text.trim(),
        categoryId: _selectedCategoryId!,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        recordDate: _dateController.text.trim(),
        doctorName:
            _doctorController.text.trim().isEmpty ? null : _doctorController.text.trim(),
        facilityName:
            _facilityController.text.trim().isEmpty ? null : _facilityController.text.trim(),
        filePath: finalFilePath,
        fileType: finalFileType,
        createdAt: widget.record?.createdAt ?? now,
        updatedAt: now,
      );

      final isEditing = widget.record != null;
      final success = isEditing
          ? await provider.updateRecord(record)
          : await provider.createRecord(record);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'Medical record updated.' : 'Medical record added successfully.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to save record.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.record != null;
    final categories = context.watch<RecordProvider>().categories;

    final hasActiveAttachment = (_newPickedFile != null) ||
        (!_removedExistingAttachment && _existingFilePath != null);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Medical Record' : 'Add Medical Record',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveRecord,
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
              // Title Field
              CustomTextField(
                controller: _titleController,
                label: 'Record Title',
                hint: 'e.g. Complete Blood Count (CBC) Results',
                prefixIcon: Icons.title_rounded,
                requiredField: true,
                textCapitalization: TextCapitalization.sentences,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a record title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selector
              const Row(
                children: [
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '*',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: _selectedCategoryId,
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
                items: categories.map((cat) {
                  return DropdownMenuItem<int>(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategoryId = val);
                },
              ),
              const SizedBox(height: 16),

              // Date Picker Field
              CustomTextField(
                controller: _dateController,
                label: 'Record Date',
                hint: 'YYYY-MM-DD',
                prefixIcon: Icons.event_note_rounded,
                requiredField: true,
                readOnly: true,
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),

              // Doctor Name
              CustomTextField(
                controller: _doctorController,
                label: 'Doctor / Physician Name',
                hint: 'e.g. Dr. Maria Santos',
                prefixIcon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Facility / Hospital Name
              CustomTextField(
                controller: _facilityController,
                label: 'Clinic / Medical Facility',
                hint: 'e.g. St. Luke Medical Arts / City Diagnostic Center',
                prefixIcon: Icons.local_hospital_outlined,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Description / Findings
              CustomTextField(
                controller: _descriptionController,
                label: 'Description & Notes',
                hint: 'Enter relevant findings, dosage instructions, or observations...',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Document Attachment Section (Priority 3)
              const Text(
                'Document Attachment (PDF or Image)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Attach medical prescriptions, lab reports, or imaging scans to keep them securely stored offline.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              if (hasActiveAttachment) ...[
                // Active preview
                if (_newPickedFile != null)
                  AttachmentPreviewCard(
                    localFile: _newPickedFile,
                    fileType: _newPickedFileType,
                    onRemove: _removeAttachment,
                  )
                else if (_existingFilePath != null)
                  AttachmentPreviewCard(
                    relativeFilePath: _existingFilePath,
                    fileType: _existingFileType,
                    onRemove: _removeAttachment,
                  ),
                const SizedBox(height: 8),
              ] else ...[
                // Attachment Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickPdf,
                        icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.error),
                        label: const Text('Attach PDF'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showImageSourceModal,
                        icon: const Icon(Icons.image_outlined, color: AppColors.primary),
                        label: const Text('Attach Image'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),

              // Save Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveRecord,
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
                          isEditing ? 'Update Medical Record' : 'Save Medical Record',
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
