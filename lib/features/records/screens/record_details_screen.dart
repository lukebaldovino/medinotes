import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/category_badge.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../models/medical_record.dart';
import '../../../providers/record_provider.dart';
import '../widgets/attachment_preview_card.dart';
import 'add_edit_record_screen.dart';

class RecordDetailsScreen extends StatelessWidget {
  final MedicalRecord record;

  const RecordDetailsScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    String formattedDate = record.recordDate;
    try {
      final parsed = DateTime.parse(record.recordDate);
      formattedDate = DateFormat('MMMM d, yyyy').format(parsed);
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Record Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Record',
            onPressed: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => AddEditRecordScreen(record: record),
                ),
              );
              if (updated == true && context.mounted) {
                Navigator.of(context).pop(); // Return to refreshed records list
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Delete Record',
            onPressed: () async {
              final confirm = await ConfirmationDialog.show(
                context: context,
                title: 'Delete Record',
                message:
                    'Are you sure you want to delete "${record.title}"? Any attached document will also be permanently removed from device storage.',
                confirmLabel: 'Delete',
                isDestructive: true,
              );

              if (confirm && context.mounted) {
                final success = await context.read<RecordProvider>().deleteRecord(record.id!);
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Record deleted successfully.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to delete record.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryBadge(
                  categoryName: record.categoryName ?? 'General',
                  iconName: record.categoryIcon,
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Record Title
            Text(
              record.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 20),

            // Facility and Doctor Info Card
            if ((record.doctorName != null && record.doctorName!.isNotEmpty) ||
                (record.facilityName != null && record.facilityName!.isNotEmpty)) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    if (record.facilityName != null && record.facilityName!.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.local_hospital_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              record.facilityName!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (record.facilityName != null &&
                        record.facilityName!.isNotEmpty &&
                        record.doctorName != null &&
                        record.doctorName!.isNotEmpty)
                      const Divider(height: 20, color: AppColors.border),
                    if (record.doctorName != null && record.doctorName!.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              record.doctorName!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Description / Notes Card
            if (record.description != null && record.description!.isNotEmpty) ...[
              const Text(
                'Clinical Notes & Description',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  record.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Attached Document Card
            if (record.hasAttachment) ...[
              const Text(
                'Attached Medical Document',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              AttachmentPreviewCard(
                relativeFilePath: record.filePath,
                fileType: record.fileType,
                isInteractive: true,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap the document above to view it in full resolution with your device viewer.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.attachment_outlined, size: 20, color: AppColors.textMuted),
                    SizedBox(width: 12),
                    Text(
                      'No documents attached to this record.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
