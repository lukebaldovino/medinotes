import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../models/doctor.dart';
import '../../../providers/visit_provider.dart';
import '../widgets/visit_list_tile.dart';
import 'add_edit_visit_screen.dart';

class VisitsScreen extends StatelessWidget {
  final Doctor? filteredDoctor;

  const VisitsScreen({super.key, this.filteredDoctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          filteredDoctor != null
              ? 'Visits with ${filteredDoctor!.fullName}'
              : 'Consultation History',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditVisitScreen(
                preselectedDoctorId: filteredDoctor?.id,
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Log Consultation'),
      ),
      body: Consumer<VisitProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.visits.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final visits = filteredDoctor != null
              ? provider.visits.where((v) => v.doctorId == filteredDoctor!.id).toList()
              : provider.visits;

          if (visits.isEmpty) {
            return EmptyStateView(
              icon: Icons.history_edu_rounded,
              title: filteredDoctor != null
                  ? 'No Visits with this Doctor'
                  : 'No Consultation History Yet',
              message: filteredDoctor != null
                  ? 'You have not recorded any clinical consultations with ${filteredDoctor!.fullName}.'
                  : 'Track your clinic visits, diagnoses, and medical advice by logging your consultations.',
              actionLabel: 'Log First Consultation',
              onActionPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddEditVisitScreen(
                      preselectedDoctorId: filteredDoctor?.id,
                    ),
                  ),
                );
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadVisits(doctorId: filteredDoctor?.id),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: visits.length,
              itemBuilder: (context, index) {
                final visit = visits[index];
                return VisitListTile(
                  visit: visit,
                  onEdit: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditVisitScreen(visit: visit),
                      ),
                    );
                  },
                  onDelete: () async {
                    final confirm = await ConfirmationDialog.show(
                      context: context,
                      title: 'Delete Consultation',
                      message:
                          'Are you sure you want to delete the record for "${visit.reason}" on ${visit.visitDate}?',
                      confirmLabel: 'Delete',
                      isDestructive: true,
                    );

                    if (confirm && context.mounted) {
                      final success =
                          await context.read<VisitProvider>().deleteVisit(visit.id!);
                      if (context.mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Consultation record deleted.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
