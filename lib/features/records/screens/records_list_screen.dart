import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/category_badge.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../providers/record_provider.dart';
import '../widgets/record_list_tile.dart';
import 'add_edit_record_screen.dart';
import 'record_details_screen.dart';

class RecordsListScreen extends StatefulWidget {
  const RecordsListScreen({super.key});

  @override
  State<RecordsListScreen> createState() => _RecordsListScreenState();
}

class _RecordsListScreenState extends State<RecordsListScreen> {
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
          'My Records',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditRecordScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),
      body: Consumer<RecordProvider>(
        builder: (context, provider, child) {
          final categories = provider.categories;
          final records = provider.records;
          final selectedCatId = provider.selectedCategoryId;
          final isFiltered = selectedCatId != null || provider.searchQuery.isNotEmpty;

          return Column(
            children: [
              // Search Input Field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => provider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search records by title...',
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

              // Categories Horizontal Scroll Filter
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isAllSelected = selectedCatId == null;
                      return ActionChip(
                        label: Text(
                          'All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isAllSelected ? FontWeight.bold : FontWeight.w600,
                            color: isAllSelected ? Colors.white : AppColors.primary,
                          ),
                        ),
                        backgroundColor: isAllSelected
                            ? AppColors.primary
                            : AppColors.primaryContainer.withValues(alpha: 0.6),
                        side: BorderSide(
                          color: isAllSelected
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.2),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onPressed: () => provider.setCategoryFilter(null),
                      );
                    }

                    final cat = categories[index - 1];
                    final isSelected = selectedCatId == cat.id;
                    return CategoryBadge(
                      categoryName: cat.name,
                      iconName: cat.icon,
                      isSelected: isSelected,
                      onTap: () => provider.setCategoryFilter(cat.id),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Records Timeline List / Empty State
              Expanded(
                child: provider.isLoading && records.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () => provider.loadRecords(),
                        child: records.isEmpty
                            ? (isFiltered
                                ? EmptyStateView(
                                    icon: Icons.search_off_rounded,
                                    title: 'No Matching Records',
                                    message:
                                        'No records found matching your search term or category filter.',
                                    actionLabel: 'Clear Filters',
                                    onActionPressed: () {
                                      _searchController.clear();
                                      provider.clearFilters();
                                    },
                                  )
                                : EmptyStateView(
                                    icon: Icons.note_add_outlined,
                                    title: 'No Medical Records Yet',
                                    message:
                                        'Start organizing your prescriptions, lab test results, and medical reports by adding your first record.',
                                    actionLabel: 'Add First Record',
                                    onActionPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const AddEditRecordScreen(),
                                        ),
                                      );
                                    },
                                  ))
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                                itemCount: records.length,
                                itemBuilder: (context, index) {
                                  final record = records[index];
                                  return RecordListTile(
                                    record: record,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RecordDetailsScreen(record: record),
                                        ),
                                      );
                                    },
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
