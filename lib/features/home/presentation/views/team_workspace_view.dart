import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/services/preparation_list_service.dart';
import 'package:stepforward/core/services/team_workspace_service.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/custom_snak_bar.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_app_bar.dart';
import 'package:stepforward/core/widgets/custom_button.dart';
import 'package:stepforward/core/widgets/custom_empty_widget.dart';
import 'package:stepforward/core/widgets/custom_text_field.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/features/home/domain/models/service_history_model.dart';
import 'package:stepforward/features/home/domain/models/team_workspace_model.dart';

class TeamWorkspaceView extends StatefulWidget {
  const TeamWorkspaceView({super.key, this.initialInviteCode});

  final String? initialInviteCode;

  @override
  State<TeamWorkspaceView> createState() => _TeamWorkspaceViewState();
}

class _TeamWorkspaceViewState extends State<TeamWorkspaceView> {
  final _createFormKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  late final TextEditingController _inviteCodeController;

  TeamWorkspaceModel? _team;
  List<GameModel> _teamPreparationGames = [];
  List<ServiceHistoryModel> _teamHistory = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _inviteCodeController = TextEditingController(
      text: widget.initialInviteCode == null
          ? ''
          : teamWorkspaceService.normalizeInviteCode(widget.initialInviteCode!),
    );
    _loadTeam();
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadTeam() async {
    setState(() => _isLoading = true);
    final team = await teamWorkspaceService.getMyTeam();
    List<GameModel> preparationGames = [];
    List<ServiceHistoryModel> history = [];

    if (team != null) {
      try {
        preparationGames = await teamWorkspaceService.getTeamPreparationGames(
          team.id,
        );
        history = await teamWorkspaceService.getTeamHistory(team.id);
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _team = team;
      _teamPreparationGames = preparationGames;
      _teamHistory = history;
      _isLoading = false;
    });
  }

  Future<void> _createTeam() async {
    if (!_createFormKey.currentState!.validate()) return;
    await _runSubmittingAction(() async {
      final team = await teamWorkspaceService.createTeam(
        _teamNameController.text,
      );
      _teamNameController.clear();
      await _setTeamAndRefresh(team);
      if (!mounted) return;
      showSnackBar(context, text: 'تم إنشاء الفريق');
    });
  }

  Future<void> _joinTeam() async {
    final code = teamWorkspaceService.normalizeInviteCode(
      _inviteCodeController.text,
    );
    if (code.isEmpty) {
      showSnackBar(context, text: 'اكتب كود الدعوة');
      return;
    }

    await _runSubmittingAction(() async {
      final team = await teamWorkspaceService.joinTeamByInviteCode(code);
      if (!mounted) return;
      if (team == null) {
        showSnackBar(context, text: 'كود الدعوة غير صحيح', color: Colors.red);
        return;
      }

      _inviteCodeController.clear();
      await _setTeamAndRefresh(team);
      if (!mounted) return;
      showSnackBar(context, text: 'تم الانضمام للفريق');
    });
  }

  Future<void> _leaveTeam() async {
    final team = _team;
    if (team == null) return;

    await _runSubmittingAction(() async {
      await teamWorkspaceService.leaveTeam(team.id);
      if (!mounted) return;
      setState(() {
        _team = null;
        _teamPreparationGames = [];
        _teamHistory = [];
      });
      showSnackBar(context, text: 'تم الخروج من الفريق');
    });
  }

  Future<void> _syncPreparationWithTeam() async {
    final team = _team;
    if (team == null) return;

    final localGames = preparationListService.getGames();
    if (localGames.isEmpty) {
      showSnackBar(context, text: 'قائمة التحضير الحالية فارغة');
      return;
    }

    await _runSubmittingAction(() async {
      await teamWorkspaceService.saveTeamPreparationGames(
        teamId: team.id,
        games: localGames,
      );
      if (!mounted) return;
      setState(() => _teamPreparationGames = localGames);
      showSnackBar(context, text: 'تم تحديث تحضير الفريق');
    });
  }

  Future<void> _addTeamHistory(ServiceHistoryModel history) async {
    final team = _team;
    if (team == null) return;

    await _runSubmittingAction(() async {
      await teamWorkspaceService.addTeamHistory(
        teamId: team.id,
        history: history,
      );
      final updatedHistory = await teamWorkspaceService.getTeamHistory(team.id);
      if (!mounted) return;
      setState(() => _teamHistory = updatedHistory);
      showSnackBar(context, text: 'تم حفظ الخدمة للفريق');
    });
  }

  Future<void> _setTeamAndRefresh(TeamWorkspaceModel team) async {
    final preparationGames = await teamWorkspaceService.getTeamPreparationGames(
      team.id,
    );
    final history = await teamWorkspaceService.getTeamHistory(team.id);
    if (!mounted) return;
    setState(() {
      _team = team;
      _teamPreparationGames = preparationGames;
      _teamHistory = history;
    });
  }

  Future<void> _runSubmittingAction(Future<void> Function() action) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await action();
    } on FirebaseException catch (error) {
      if (!mounted) return;
      showSnackBar(
        context,
        text: _firebaseErrorMessage(error),
        color: Colors.red,
      );
    } catch (error) {
      if (!mounted) return;
      showSnackBar(context, text: 'حدث خطأ: $error', color: Colors.red);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _firebaseErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Firebase رفض الحفظ: محتاج تفتح صلاحيات teams في Firestore Rules';
      case 'unauthenticated':
        return 'لازم تعمل تسجيل دخول قبل إنشاء الفريق';
      case 'unavailable':
        return 'Firebase غير متاح الآن، راجع الاتصال وحاول مرة أخرى';
      default:
        return 'Firebase error: ${error.code}';
    }
  }

  Future<void> _copyText(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    showSnackBar(context, text: message);
  }

  Future<void> _shareInviteLink() async {
    final team = _team;
    if (team == null) return;
    final link = teamWorkspaceService.buildInviteLink(team.inviteCode);
    await Share.share(
      'انضم لفريق ${team.name} على Step Forward\n$link',
      subject: team.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: buildAppBar(
        context,
        title: isEn ? 'My Team' : 'فريقي',
        onTap: () => context.pop(),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                kHorizontalPadding,
                kVerticalPadding,
                kHorizontalPadding,
                kVerticalPadding + bottomSafeArea + 24,
              ),
              child: _team == null
                  ? _buildJoinOrCreateView()
                  : _buildTeamView(),
            ),
    );
  }

  Widget _buildJoinOrCreateView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionBox(
          child: Form(
            key: _createFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('إنشاء فريق جديد', style: TextStyles.bold19),
                verticalSpace(12),
                CustomTextFormField(
                  controller: _teamNameController,
                  hintText: 'اسم الفريق',
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                ),
                verticalSpace(12),
                CustomButton(
                  text: _isSubmitting ? 'جاري الحفظ...' : 'إنشاء الفريق',
                  onPressed: _isSubmitting ? null : _createTeam,
                ),
              ],
            ),
          ),
        ),
        verticalSpace(14),
        _SectionBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('الانضمام لفريق', style: TextStyles.bold19),
              verticalSpace(12),
              CustomTextFormField(
                controller: _inviteCodeController,
                hintText: 'كود الدعوة',
                textInputType: TextInputType.text,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\- ]')),
                ],
                onFieldSubmitted: (_) => _joinTeam(),
              ),
              verticalSpace(12),
              CustomButton(
                text: _isSubmitting ? 'جاري الدخول...' : 'انضمام',
                onPressed: _isSubmitting ? null : _joinTeam,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamView() {
    final team = _team!;
    final inviteLink = teamWorkspaceService.buildInviteLink(team.inviteCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.groups_rounded,
                    color: AppColors.primaryColor,
                  ),
                  horizontalSpace(8),
                  Expanded(
                    child: Text(
                      team.name,
                      style: TextStyles.bold23.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpace(10),
              Text('الأعضاء: ${team.memberCount}', style: TextStyles.regular14),
              verticalSpace(12),
              _InviteCodeBox(code: team.inviteCode),
              verticalSpace(12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SmallActionButton(
                    icon: Icons.copy_rounded,
                    label: 'نسخ الكود',
                    onTap: () => _copyText(team.inviteCode, 'تم نسخ الكود'),
                  ),
                  _SmallActionButton(
                    icon: Icons.link_rounded,
                    label: 'نسخ الرابط',
                    onTap: () => _copyText(inviteLink, 'تم نسخ الرابط'),
                  ),
                  _SmallActionButton(
                    icon: Icons.ios_share_rounded,
                    label: 'مشاركة',
                    onTap: _shareInviteLink,
                  ),
                ],
              ),
            ],
          ),
        ),
        verticalSpace(14),
        _buildPreparationSection(),
        verticalSpace(14),
        _buildTeamHistorySection(),
        verticalSpace(18),
        TextButton.icon(
          onPressed: _isSubmitting ? null : _leaveTeam,
          icon: const Icon(Icons.logout_rounded, color: Colors.red),
          label: Text(
            'الخروج من الفريق',
            style: TextStyles.bold16.copyWith(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildPreparationSection() {
    final tools = _teamPreparationGames
        .expand((game) => _extractTools(game.tools).map((tool) => (game, tool)))
        .toList();

    return _SectionBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.checklist_rounded,
                color: AppColors.primaryColor,
              ),
              horizontalSpace(8),
              const Expanded(
                child: Text('تحضير الفريق', style: TextStyles.bold19),
              ),
            ],
          ),
          verticalSpace(10),
          CustomButton(
            text: _isSubmitting
                ? 'جاري التحديث...'
                : 'مزامنة قائمة التحضير الحالية',
            height: 46,
            borderRadius: 12,
            onPressed: _isSubmitting ? null : _syncPreparationWithTeam,
          ),
          verticalSpace(12),
          if (_teamPreparationGames.isEmpty)
            const CustomEmptyWidget(
              title: 'لا توجد قائمة تحضير للفريق',
              subtitle: 'أضف ألعاب لقائمة التحضير ثم اضغط مزامنة.',
            )
          else ...[
            Text(
              'الألعاب: ${_teamPreparationGames.length} | الأدوات: ${tools.length}',
              style: TextStyles.semiBold13,
            ),
            verticalSpace(8),
            ..._teamPreparationGames.map((game) {
              final gameTools = _extractTools(game.tools);
              return ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                title: Text(game.name, style: TextStyles.bold16),
                subtitle: Text(
                  '${gameTools.length} أدوات',
                  style: TextStyles.regular13,
                ),
                children: gameTools
                    .map(
                      (tool) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColors.primaryColor,
                        ),
                        title: Text(tool, style: TextStyles.regular14),
                      ),
                    )
                    .toList(),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamHistorySection() {
    return _SectionBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, color: AppColors.primaryColor),
              horizontalSpace(8),
              const Expanded(
                child: Text('خدمات الفريق', style: TextStyles.bold19),
              ),
              IconButton(
                tooltip: 'إضافة خدمة',
                onPressed: _isSubmitting ? null : _showAddHistorySheet,
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          if (_teamHistory.isEmpty)
            const CustomEmptyWidget(
              title: 'لا توجد خدمات محفوظة',
              subtitle: 'اضغط + واحفظ خدمة للفريق كله.',
            )
          else
            ..._teamHistory.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.title, style: TextStyles.bold16),
                subtitle: Text(
                  [
                    if (item.place.isNotEmpty) item.place,
                    if (item.ageGroup.isNotEmpty) item.ageGroup,
                    _formatDate(item.date),
                  ].join(' - '),
                  style: TextStyles.regular13,
                ),
                trailing: Text(
                  '${item.games.length} ألعاب',
                  style: TextStyles.semiBold13.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddTeamHistorySheet(onSave: _addTeamHistory),
    );
  }

  List<String> _extractTools(String value) {
    final plainText = value
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</(p|li|div)>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'[•\-]+'), '\n')
        .replaceAll(RegExp(r'\r'), '\n')
        .trim();

    final lines = plainText
        .split(RegExp(r'\n+'))
        .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isNotEmpty) return lines;
    return plainText.isEmpty ? [] : [plainText];
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('إضافة خدمة للفريق', style: TextStyles.bold19),
              verticalSpace(14),
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
                minLines: 2,
                maxLines: 5,
                needsValidation: false,
              ),
              verticalSpace(10),
              CustomTextFormField(
                controller: _notesController,
                hintText: 'ملاحظات',
                textInputType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 2,
                maxLines: 4,
                needsValidation: false,
              ),
              verticalSpace(10),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text('${_date.day}/${_date.month}/${_date.year}'),
              ),
              verticalSpace(14),
              CustomButton(
                text: _isSaving ? 'جاري الحفظ...' : 'حفظ للفريق',
                onPressed: _isSaving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionBox extends StatelessWidget {
  const _SectionBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.16),
        ),
      ),
      child: child,
    );
  }
}

class _InviteCodeBox extends StatelessWidget {
  const _InviteCodeBox({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('كود الدعوة', style: TextStyles.semiBold13),
          const Spacer(),
          Text(
            code,
            textDirection: TextDirection.ltr,
            style: TextStyles.bold19.copyWith(color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        side: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.25)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
