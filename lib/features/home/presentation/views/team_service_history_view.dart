import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/services/service_history_service.dart';
import 'package:stepforward/core/services/team_workspace_service.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/custom_snak_bar.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_app_bar.dart';
import 'package:stepforward/core/widgets/custom_empty_widget.dart';
import 'package:stepforward/core/widgets/custom_text_field.dart';
import 'package:stepforward/core/widgets/search_text_field.dart';
import 'package:stepforward/features/home/domain/models/service_history_model.dart';
import 'package:stepforward/features/home/domain/models/team_workspace_model.dart';

class TeamServiceHistoryView extends StatefulWidget {
  const TeamServiceHistoryView({super.key, required this.team});

  final TeamWorkspaceModel team;

  @override
  State<TeamServiceHistoryView> createState() => _TeamServiceHistoryViewState();
}

class _TeamServiceHistoryViewState extends State<TeamServiceHistoryView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _shareLocalHistoryWithTeam();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _shareLocalHistoryWithTeam() async {
    final localHistory = serviceHistoryService.getCachedHistory();
    if (localHistory.isEmpty) return;

    try {
      for (final item in localHistory) {
        await teamWorkspaceService.addTeamHistory(
          teamId: widget.team.id,
          history: item,
        );
      }
    } catch (_) {
      if (!mounted) return;
      showSnackBar(
        context,
        text: 'تعذر مشاركة الخدمات مع الفريق. راجع صلاحيات Firebase.',
        color: Colors.red,
      );
    }
  }

  Future<void> _addHistory(ServiceHistoryModel history) async {
    try {
      await teamWorkspaceService.addTeamHistory(
        teamId: widget.team.id,
        history: history,
      );
      if (!mounted) return;
      showSnackBar(context, text: 'تم حفظ الخدمة للفريق');
    } on FirebaseException catch (error) {
      if (!mounted) return;
      showSnackBar(
        context,
        text: error.code == 'permission-denied'
            ? 'Firebase رفض الحفظ: راجع صلاحيات teams/serviceHistory'
            : 'Firebase error: ${error.code}',
        color: Colors.red,
      );
    }
  }

  Future<void> _openAddSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddTeamHistorySheet(onSave: _addHistory),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: buildAppBar(
        context,
        title: 'خدمات الفريق',
        onTap: () => context.pop(),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('إضافة'),
      ),
      body: StreamBuilder<List<ServiceHistoryModel>>(
        stream: teamWorkspaceService.watchTeamHistory(widget.team.id),
        builder: (context, snapshot) {
          final history = snapshot.data ?? [];
          final filteredHistory = history
              .where((item) => item.matches(_searchController.text))
              .toList();

          return ListView(
            padding: EdgeInsets.fromLTRB(
              kHorizontalPadding,
              kVerticalPadding,
              kHorizontalPadding,
              kVerticalPadding + bottomSafeArea + 72,
            ),
            children: [
              SearchTextField(
                controller: _searchController,
                hintText: 'ابحث بالخدمة أو المكان أو اللعبة أو الملاحظات',
                onChanged: (_) => setState(() {}),
              ),
              verticalSpace(16),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (snapshot.hasError)
                const CustomEmptyWidget(
                  title: 'تعذر تحميل الخدمات',
                  subtitle: 'راجع صلاحيات الفريق أو الاتصال بالإنترنت.',
                )
              else if (history.isEmpty)
                const CustomEmptyWidget(
                  title: 'لا توجد خدمات محفوظة',
                  subtitle: 'أي خدمة يضيفها عضو ستظهر هنا تلقائيًا.',
                )
              else if (filteredHistory.isEmpty)
                const CustomEmptyWidget(
                  title: 'لا توجد نتائج',
                  subtitle: 'جرّب اسم خدمة أو مكان أو لعبة مختلف.',
                )
              else
                ...filteredHistory.map((item) => _TeamHistoryCard(item: item)),
            ],
          );
        },
      ),
    );
  }
}

class _TeamHistoryCard extends StatelessWidget {
  const _TeamHistoryCard({required this.item});

  final ServiceHistoryModel item;

  @override
  Widget build(BuildContext context) {
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
          Text(
            item.title,
            style: TextStyles.bold16.copyWith(color: AppColors.primaryColor),
          ),
          verticalSpace(8),
          Text(
            [
              if (item.place.isNotEmpty) item.place,
              if (item.ageGroup.isNotEmpty) item.ageGroup,
              _formatDate(item.date),
            ].join(' - '),
            style: TextStyles.regular13,
          ),
          if (item.games.isNotEmpty) ...[
            verticalSpace(10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.games
                  .map(
                    (game) => Chip(
                      label: Text(game),
                      backgroundColor: AppColors.primaryColor.withValues(
                        alpha: 0.08,
                      ),
                      side: BorderSide(
                        color: AppColors.primaryColor.withValues(alpha: 0.12),
                      ),
                    ),
                  )
                  .toList(),
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

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _AddTeamHistorySheet extends StatefulWidget {
  const _AddTeamHistorySheet({required this.onSave});

  final Future<void> Function(ServiceHistoryModel history) onSave;

  @override
  State<_AddTeamHistorySheet> createState() => _AddTeamHistorySheetState();
}

class _AddTeamHistorySheetState extends State<_AddTeamHistorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _placeController = TextEditingController();
  final _ageGroupController = TextEditingController();
  final _gamesController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _ageGroupController.dispose();
    _gamesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final games = _gamesController.text
        .split(RegExp(r'[\n,،]+'))
        .map((game) => game.trim())
        .where((game) => game.isNotEmpty)
        .toList();

    final history = ServiceHistoryModel(
      id: '',
      title: _titleController.text.trim(),
      place: _placeController.text.trim(),
      date: _date,
      games: games,
      ageGroup: _ageGroupController.text.trim(),
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    await widget.onSave(history);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
              const Text('إضافة خدمة للفريق', style: TextStyles.bold19),
              verticalSpace(14),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextFormField(
                        controller: _titleController,
                        hintText: 'اسم الخدمة',
                        textInputType: TextInputType.text,
                      ),
                      verticalSpace(10),
                      CustomTextFormField(
                        controller: _placeController,
                        hintText: 'المكان',
                        textInputType: TextInputType.text,
                        needsValidation: false,
                      ),
                      verticalSpace(10),
                      CustomTextFormField(
                        controller: _ageGroupController,
                        hintText: 'السن أو المرحلة',
                        textInputType: TextInputType.text,
                        needsValidation: false,
                      ),
                      verticalSpace(10),
                      CustomTextFormField(
                        controller: _gamesController,
                        hintText: 'الألعاب المستخدمة، كل لعبة في سطر',
                        textInputType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        minLines: 3,
                        maxLines: 5,
                        needsValidation: false,
                      ),
                      verticalSpace(10),
                      CustomTextFormField(
                        controller: _notesController,
                        hintText: 'ملاحظات',
                        textInputType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        minLines: 3,
                        maxLines: 4,
                        needsValidation: false,
                      ),
                      verticalSpace(10),
                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month_rounded),
                        label: Text(
                          '${_date.day}/${_date.month}/${_date.year}',
                        ),
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
                  label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ للفريق'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
