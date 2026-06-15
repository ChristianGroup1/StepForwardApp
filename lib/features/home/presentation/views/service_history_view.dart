import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/services/service_history_service.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_app_bar.dart';
import 'package:stepforward/core/widgets/custom_empty_widget.dart';
import 'package:stepforward/core/widgets/custom_text_field.dart';
import 'package:stepforward/core/widgets/search_text_field.dart';
import 'package:stepforward/features/home/domain/models/service_history_model.dart';

class ServiceHistoryView extends StatefulWidget {
  const ServiceHistoryView({super.key});

  @override
  State<ServiceHistoryView> createState() => _ServiceHistoryViewState();
}

class _ServiceHistoryViewState extends State<ServiceHistoryView> {
  final _searchController = TextEditingController();
  List<ServiceHistoryModel> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await serviceHistoryService.getHistory();
    if (!mounted) return;
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  List<ServiceHistoryModel> get _filteredHistory {
    final query = _searchController.text;
    return _history.where((item) => item.matches(query)).toList();
  }

  Future<void> _deleteHistory(ServiceHistoryModel item) async {
    await serviceHistoryService.deleteHistory(item.id);
    if (!mounted) return;
    setState(() => _history.removeWhere((history) => history.id == item.id));
  }

  Future<void> _openAddSheet() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _AddServiceHistorySheet(),
    );

    if (added == true) await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;
    final filteredHistory = _filteredHistory;

    return Scaffold(
      appBar: buildAppBar(
        context,
        title: isEn ? 'Old Services' : 'خدمات قديمة',
        onTap: () => context.pop(),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        icon: const Icon(Icons.add_rounded),
        label: Text(isEn ? 'Add' : 'إضافة'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: kHorizontalPadding,
            vertical: kVerticalPadding,
          ),
          children: [
            SearchTextField(
              controller: _searchController,
              hintText: isEn
                  ? 'Search service, place, game, notes'
                  : 'ابحث بالخدمة أو المكان أو اللعبة أو الملاحظات',
              onChanged: (_) => setState(() {}),
            ),
            verticalSpace(16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_history.isEmpty)
              CustomEmptyWidget(
                title: isEn ? 'No old services yet' : 'لا توجد خدمات قديمة',
                subtitle: isEn
                    ? 'Add the services and games you used before.'
                    : 'أضف الخدمات والألعاب التي استخدمتها قبل ذلك.',
              )
            else if (filteredHistory.isEmpty)
              CustomEmptyWidget(
                title: isEn ? 'No matching results' : 'لا توجد نتائج',
                subtitle: isEn
                    ? 'Try another service, place, or game name.'
                    : 'جرّب اسم خدمة أو مكان أو لعبة مختلف.',
              )
            else
              ...filteredHistory.map(
                (item) => _ServiceHistoryCard(
                  item: item,
                  onDelete: () => _deleteHistory(item),
                ),
              ),
            verticalSpace(72),
          ],
        ),
      ),
    );
  }
}

class _ServiceHistoryCard extends StatelessWidget {
  const _ServiceHistoryCard({required this.item, required this.onDelete});

  final ServiceHistoryModel item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyles.bold16.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              IconButton(
                tooltip: isEn ? 'Delete' : 'حذف',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
          if (item.place.isNotEmpty) ...[
            verticalSpace(4),
            _InfoRow(icon: Icons.place_outlined, text: item.place),
          ],
          verticalSpace(4),
          _InfoRow(
            icon: Icons.event_outlined,
            text: _formatDate(item.date, isEn),
          ),
          if (item.ageGroup.isNotEmpty) ...[
            verticalSpace(4),
            _InfoRow(icon: Icons.groups_2_outlined, text: item.ageGroup),
          ],
          if (item.games.isNotEmpty) ...[
            verticalSpace(10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.games.map((game) {
                return Chip(
                  label: Text(game),
                  backgroundColor: AppColors.primaryColor.withValues(
                    alpha: 0.08,
                  ),
                  side: BorderSide(
                    color: AppColors.primaryColor.withValues(alpha: 0.12),
                  ),
                );
              }).toList(),
            ),
          ],
          if (item.notes.isNotEmpty) ...[
            verticalSpace(10),
            Text(item.notes, style: TextStyles.regular14),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date, bool isEn) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return isEn ? '$month/$day/${date.year}' : '$day/$month/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryColor),
        horizontalSpace(6),
        Expanded(
          child: Text(
            text,
            style: TextStyles.regular14.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.76),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddServiceHistorySheet extends StatefulWidget {
  const _AddServiceHistorySheet();

  @override
  State<_AddServiceHistorySheet> createState() =>
      _AddServiceHistorySheetState();
}

class _AddServiceHistorySheetState extends State<_AddServiceHistorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _placeController = TextEditingController();
  final _gamesController = TextEditingController();
  final _ageGroupController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _gamesController.dispose();
    _ageGroupController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;
    setState(() => _date = pickedDate);
  }

  Future<void> _save() async {
    final isEn = context.isEn;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await serviceHistoryService.addHistory(
        ServiceHistoryModel(
          id: '',
          title: _titleController.text.trim(),
          place: _placeController.text.trim(),
          date: _date,
          games: _extractGames(),
          ageGroup: _ageGroupController.text.trim(),
          notes: _notesController.text.trim(),
          createdAt: DateTime.now(),
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEn ? 'Could not save service' : 'تعذر حفظ الخدمة'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  List<String> _extractGames() {
    return _gamesController.text
        .split(RegExp(r'[\n,،]+'))
        .map((game) => game.trim())
        .where((game) => game.isNotEmpty)
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          bottomInset + bottomSafeArea + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              verticalSpace(14),
              Text(
                isEn ? 'Add Old Service' : 'إضافة خدمة قديمة',
                style: TextStyles.bold19.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              verticalSpace(14),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextFormField(
                        controller: _titleController,
                        labelText: isEn ? 'Service name' : 'اسم الخدمة',
                        hintText: isEn ? 'Friday service' : 'خدمة الجمعة',
                      ),
                      verticalSpace(10),
                      CustomTextFormField(
                        controller: _placeController,
                        labelText: isEn ? 'Place' : 'المكان',
                        hintText: isEn ? 'Church hall' : 'قاعة الكنيسة',
                        needsValidation: false,
                      ),
                      verticalSpace(10),
                      CustomTextFormField(
                        controller: _ageGroupController,
                        labelText: isEn ? 'Age group' : 'المرحلة',
                        hintText: isEn ? 'Middle school' : 'أولى إعدادي',
                        needsValidation: false,
                      ),
                      verticalSpace(10),
                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.event_outlined),
                        label: Text(_formatDate(_date, isEn)),
                      ),
                      verticalSpace(10),
                      CustomTextFormField(
                        controller: _gamesController,
                        labelText: isEn ? 'Played games' : 'الألعاب المستخدمة',
                        hintText: isEn
                            ? 'One game per line'
                            : 'كل لعبة في سطر\nمثال:\nلعبة الثقة\nلعبة الكنز',
                        textInputType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        minLines: 3,
                        maxLines: 4,
                        needsValidation: false,
                      ),
                      verticalSpace(10),
                      CustomTextFormField(
                        controller: _notesController,
                        labelText: isEn ? 'Notes' : 'ملاحظات',
                        hintText: isEn
                            ? 'What worked? What should change?'
                            : 'إيه اللي نجح؟ وإيه اللي محتاج يتغير؟',
                        textInputType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        minLines: 3,
                        maxLines: 4,
                        needsValidation: false,
                      ),
                      verticalSpace(12),
                    ],
                  ),
                ),
              ),
              verticalSpace(12),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(isEn ? 'Save service' : 'حفظ الخدمة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, bool isEn) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return isEn ? '$month/$day/${date.year}' : '$day/$month/${date.year}';
  }
}
