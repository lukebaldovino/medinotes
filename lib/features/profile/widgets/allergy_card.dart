import 'package:material_ui/material_ui.dart';
import '../../../core/constants/app_colors.dart';

class AllergyCard extends StatelessWidget {
  final String? allergies;

  const AllergyCard({super.key, this.allergies});

  @override
  Widget build(BuildContext context) {
    final hasAllergies = allergies != null && allergies!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasAllergies ? AppColors.errorContainer : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasAllergies ? AppColors.error.withValues(alpha: 0.3) : AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasAllergies ? AppColors.error : AppColors.textMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasAllergies ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAllergies ? 'Known Allergies' : 'No Known Allergies',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: hasAllergies ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasAllergies
                      ? allergies!
                      : 'No allergies have been recorded for this patient.',
                  style: TextStyle(
                    fontSize: 13,
                    color: hasAllergies ? const Color(0xFF7F1D1D) : AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
