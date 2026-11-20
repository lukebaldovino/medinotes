import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/doctor.dart';
import '../../../providers/doctor_provider.dart';
import '../../visits/screens/add_edit_visit_screen.dart';
import '../../visits/screens/visits_screen.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback? onLogConsultation;

  const DoctorDetailsScreen({
    super.key,
    required this.doctor,
    this.onLogConsultation,
  });

  String _getInitials(String name) {
    final clean = name.replaceAll(RegExp(r'^(Dr\.|Dra\.|Atty\.)\s*', caseSensitive: false), '').trim();
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'DR';
  }

  @override
  Widget build(BuildContext context) {
    final currentDoctor = context.watch<DoctorProvider>().doctors.firstWhere(
          (d) => d.id == doctor.id,
          orElse: () => doctor,
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctor Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              currentDoctor.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: currentDoctor.isFavorite ? AppColors.accent : AppColors.textMuted,
              size: 26,
            ),
            tooltip: currentDoctor.isFavorite ? 'Remove Favorite' : 'Add to Favorites',
            onPressed: () => context.read<DoctorProvider>().toggleFavorite(currentDoctor),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top Card with Doctor Avatar & Specialty
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      _getInitials(currentDoctor.fullName),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentDoctor.fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentDoctor.specialty,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Clinic & Contact Information Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clinic & Practice Information',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Divider(height: 24, color: AppColors.border),
                  _buildDetailRow(
                    icon: Icons.business_outlined,
                    label: 'Clinic / Hospital',
                    value: currentDoctor.clinicName,
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address & Room',
                    value: currentDoctor.address,
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Contact Number',
                    value: currentDoctor.contactNumber,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bio & Clinical Experience Card
            if (currentDoctor.description != null && currentDoctor.description!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About Physician',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Divider(height: 24, color: AppColors.border),
                    Text(
                      currentDoctor.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action: Log Consultation
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddEditVisitScreen(
                        preselectedDoctorId: currentDoctor.id,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Log Consultation with Doctor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Action: View Past Consultations with this doctor
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VisitsScreen(
                        filteredDoctor: currentDoctor,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history_edu_outlined, size: 20),
                label: const Text('View Consultations with this Doctor'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
