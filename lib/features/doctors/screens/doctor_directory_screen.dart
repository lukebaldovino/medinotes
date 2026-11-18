import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../providers/doctor_provider.dart';
import '../widgets/doctor_list_card.dart';
import 'doctor_details_screen.dart';

class DoctorDirectoryScreen extends StatefulWidget {
  const DoctorDirectoryScreen({super.key});

  @override
  State<DoctorDirectoryScreen> createState() => _DoctorDirectoryScreenState();
}

class _DoctorDirectoryScreenState extends State<DoctorDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find Doctors',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Consumer<DoctorProvider>(
        builder: (context, provider, child) {
          final doctors = provider.doctors;
          final specialties = provider.specialties;
          final selectedSpecialty = provider.selectedSpecialty;
          final isFiltered = selectedSpecialty != 'All' || provider.searchQuery.isNotEmpty;

          return Column(
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => provider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search doctors by name or clinic...',
                    hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),

              // Specialties Filter Chips
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: specialties.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final specialty = specialties[index];
                    final isSelected = selectedSpecialty == specialty;
                    return ActionChip(
                      label: Text(
                        specialty,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                      backgroundColor: isSelected
                          ? AppColors.primary
                          : AppColors.primaryContainer.withValues(alpha: 0.6),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.2),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onPressed: () => provider.setSpecialty(specialty),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Doctor List
              Expanded(
                child: provider.isLoading && doctors.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () => provider.loadDoctors(),
                        child: doctors.isEmpty
                            ? EmptyStateView(
                                icon: Icons.person_search_rounded,
                                title: isFiltered ? 'No Doctors Match Search' : 'No Doctors Listed',
                                message: isFiltered
                                    ? 'Try modifying your search keywords or clearing specialty filters.'
                                    : 'No doctors are currently available in the directory.',
                                actionLabel: isFiltered ? 'Clear Filters' : null,
                                onActionPressed: isFiltered
                                    ? () {
                                        _searchController.clear();
                                        provider.clearFilters();
                                      }
                                    : null,
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                itemCount: doctors.length,
                                itemBuilder: (context, index) {
                                  final doctor = doctors[index];
                                  return DoctorListCard(
                                    doctor: doctor,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DoctorDetailsScreen(doctor: doctor),
                                        ),
                                      );
                                    },
                                    onFavoriteToggle: () => provider.toggleFavorite(doctor),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
