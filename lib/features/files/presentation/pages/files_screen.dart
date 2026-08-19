import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:open_filex/open_filex.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';
import 'package:rmscanner/features/files/data/models/file_model.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_bloc.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_event.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_state.dart';
import 'package:rmscanner/features/files/presentation/widgets/file_item.dart';
import 'package:rmscanner/core/utils/file_action_helper.dart';
import 'package:rmscanner/core/widgets/custom_bottom_sheet.dart';
import 'package:rmscanner/core/widgets/global_snackbar.dart';
import 'package:rmscanner/core/constants/app_colors.dart';
import 'package:rmscanner/core/utils/dimensions.dart';
import 'package:rmscanner/core/utils/styles.dart';
import 'package:rmscanner/core/widgets/custom_app_bar.dart';

class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const _FilesScreenContent();
  }
}

class _FilesScreenContent extends StatefulWidget {
  const _FilesScreenContent();
  @override
  State<_FilesScreenContent> createState() => _FilesScreenContentState();
}

class _FilesScreenContentState extends State<_FilesScreenContent>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTabIndex = 0;
  void _onTabTapped(int index) {
    setState(() => _selectedTabIndex = index);
    final bloc = context.read<FilesBloc>();
    switch (index) {
      case 0:
        bloc.add(LoadFiles());
        break;
      case 1:
        bloc.add(const LoadFilesByType(FileType.pdf));
        break;
      case 2:
        bloc.add(const LoadFilesByType(FileType.image));
        break;
      case 3:
        bloc.add(const LoadFilesByType(FileType.text));
        break;
    }
  }

  void _showSortMenu(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showCustomBottomSheet(
      context: context,
      title: loc.tr('sort_by'),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(loc.tr('sort_date')),
              onTap: () {
                context.read<FilesBloc>().add(
                  const SortFiles(FileSortType.date),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: Text(loc.tr('sort_name')),
              onTap: () {
                context.read<FilesBloc>().add(
                  const SortFiles(FileSortType.name),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.data_usage_outlined),
              title: Text(loc.tr('sort_size')),
              onTap: () {
                context.read<FilesBloc>().add(
                  const SortFiles(FileSortType.size),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: CustomAppBar(
        title: loc.tr('files'),
        actionIcon: Icons.sort,
        onActionTap: () => _showSortMenu(context),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {});
                  if (value.isNotEmpty) {
                    context.read<FilesBloc>().add(SearchFiles(value));
                  } else {
                    _onTabTapped(_selectedTabIndex);
                  }
                },
                decoration: InputDecoration(
                  hintText: loc.tr('search_hint'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () {
                            _searchController.clear();
                            _onTabTapped(_selectedTabIndex);
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          // Custom Tab Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildTab(0, loc.tr('tab_recent'), Icons.access_time_rounded),
                _buildTab(1, loc.tr('tab_pdfs'), Icons.picture_as_pdf_outlined),
                _buildTab(2, loc.tr('tab_images'), Icons.image_outlined),
                _buildTab(3, loc.tr('tab_ocr_text'), Icons.text_fields_outlined),
              ],
            ),
          ),
          const Gap(16),
          // Files List
          Expanded(
            child: BlocBuilder<FilesBloc, FilesState>(
              builder: (context, state) {
                if (state is FilesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is FilesLoaded) {
                  if (state.files.isEmpty) return _buildEmptyState(context);
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.files.length,
                    itemBuilder: (context, index) {
                      final file = state.files[index];
                      return FileItem(
                            title: file.name,
                            date: file.formattedDate(AppLocalizations.of(context)),
                            size: file.formattedSize,
                            type: file.type.name,
                            onTap: () => _openFile(context, file),
                            onMoreTap: () =>
                                FileActionHelper.showFileOptions(context, file),
                          )
                          .animate()
                          .fadeIn(delay: (index * 50).ms)
                          .slideY(begin: 0.1);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: Dimensions.icon48,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const Gap(Dimensions.gapXL),
          Text(AppLocalizations.of(context).tr('no_files_found'), style: Styles.emptyStateTitle(context)),
        ],
      ),
    );
  }

  Future<void> _openFile(BuildContext context, FileModel file) async {
    try {
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && context.mounted) {
        GlobalSnackBar.showError(
          AppLocalizations.of(context).tr('could_not_open_file'),
        );
      }
    } catch (e) {
      if (context.mounted) {
        GlobalSnackBar.showError(
          AppLocalizations.of(context).tr('error_opening_file'),
        );
      }
    }
  }
}
