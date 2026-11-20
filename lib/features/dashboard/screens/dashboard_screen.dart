import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/patient_provider.dart';
import '../../../providers/record_provider.dart';
import '../../../providers/visit_provider.dart';
import '../../profile/screens/edit_profile_screen.dart';
import '../../records/screens/add_edit_record_screen.dart';
import '../../records/screens/record_details_screen.dart';
import '../../records/widgets/record_list_tile.dart';
import '../../visits/screens/add_edit_visit_screen.dart';
import '../../visits/screens/visits_screen.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  final void Function(int tabIndex) onNavigateToTab;

  const DashboardScreen({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final todayFormatted = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              context.read<PatientProvider>().loadProfile(),
              context.read<RecordProvider>().initialize(),
              context.read<VisitProvider>().loadVisits(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Greeting & Patient Avatar
                Consumer<PatientProvider>(
                  builder: (context, provider, child) {
                    final patient = provider.patient;
                    final firstName = patient != null && patient.fullName.trim().isNotEmpty
                        ? patient.fullName.trim().split(' ').first
                        : null;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                todayFormatted,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                firstName != null ? 'Hello, $firstName' : 'Welcome to MediNotes',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => onNavigateToTab(3), // Navigate to Profile tab
                          borderRadius: BorderRadius.circular(24),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              provider.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Patient Profile Summary Banner
                Consumer<PatientProvider>(
                  builder: (context, provider, child) {
                    final patient = provider.patient;
                    if (patient == null) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.health_and_safety_outlined,
                              color: AppColors.primary,
                              size: 32,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Set Up Your Medical Profile',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Record your blood type, emergency contact, and allergies.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfileScreen(),
                                  ),
                                );
                              },
                              child: const Text('Setup', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    }

                    // Profile Summary Pill
                    final hasAllergies =
                        patient.allergies != null && patient.allergies!.trim().isNotEmpty;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          if (patient.bloodType != null && patient.bloodType!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bloodtype_rounded, size: 14, color: AppColors.error),
                                  const SizedBox(width: 4),
                                  Text(
                                    patient.bloodType!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: hasAllergies
                                ? Text(
                                    '⚠️ Allergies: ${patient.allergies!}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.error,
                                    ),
                                  )
                                : const Text(
                                    'No known allergies recorded',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                          ),
                          InkWell(
                            onTap: () => onNavigateToTab(3),
                            child: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Stats Row
                Consumer2<RecordProvider, VisitProvider>(
                  builder: (context, recordProv, visitProv, child) {
                    final recordsCount = recordProv.totalRecordsCount;
                    // `visits` may be scoped to one doctor by a filtered load,
                    // so the global count comes from the provider's total.
                    final visitsCount = visitProv.totalVisitsCount;

                    return Row(
                      children: [
                        StatCard(
                          title: 'Medical Records',
                          value: recordsCount.toString(),
                          icon: Icons.description_outlined,
                          color: AppColors.primary,
                          onTap: () => onNavigateToTab(1),
                        ),
                        const SizedBox(width: 12),
                        StatCard(
                          title: 'Consultations',
                          value: visitsCount.toString(),
                          icon: Icons.history_edu_outlined,
                          color: AppColors.secondary,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const VisitsScreen()),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    QuickActionButton(
                      label: 'Add Record',
                      icon: Icons.note_add_outlined,
                      backgroundColor: AppColors.primaryContainer,
                      iconColor: AppColors.primary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddEditRecordScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    QuickActionButton(
                      label: 'Log Visit',
                      icon: Icons.edit_calendar_outlined,
                      backgroundColor: AppColors.secondaryContainer,
                      iconColor: AppColors.secondary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddEditVisitScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    QuickActionButton(
                      label: 'Find Doctor',
                      icon: Icons.person_search_outlined,
                      backgroundColor: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      onTap: () => onNavigateToTab(2),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Consultation History Card
                Consumer<VisitProvider>(
                  builder: (context, visitProv, child) {
                    final latest = visitProv.latestVisit;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.history_edu_rounded, size: 18, color: AppColors.primary),
                                  SizedBox(width: 8),
                                  Text(
                                    'Consultation History',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const VisitsScreen()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'View All',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 18, color: AppColors.border),
                          if (latest != null) ...[
                            Text(
                              latest.reason,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${latest.visitDate} ${latest.doctorName != null ? '• ${latest.doctorName!}' : ''}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (latest.diagnosis != null && latest.diagnosis!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Diagnosis: ${latest.diagnosis!}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ] else ...[
                            const Text(
                              'No consultations logged yet.',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Recent Medical Records Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Medical Records',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => onNavigateToTab(1),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Consumer<RecordProvider>(
                  builder: (context, provider, child) {
                    final recent = provider.recentRecords;
                    if (provider.isLoading && recent.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (recent.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.note_alt_outlined, size: 36, color: AppColors.textMuted),
                            const SizedBox(height: 8),
                            const Text(
                              'No medical records added yet',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Keep your prescriptions and test results organized in one place.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AddEditRecordScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Record'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: recent.map((record) {
                        return RecordListTile(
                          record: record,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RecordDetailsScreen(record: record),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
