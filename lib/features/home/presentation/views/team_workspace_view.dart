import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/services/preparation_list_service.dart';
import 'package:stepforward/core/services/service_history_service.dart';
import 'package:stepforward/core/services/team_workspace_service.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/custom_snak_bar.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_app_bar.dart';
import 'package:stepforward/core/widgets/custom_button.dart';
import 'package:stepforward/core/widgets/custom_text_field.dart';
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
  List<TeamWorkspaceModel> _teams = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isTeamFormSheetOpen = false;

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
    final cachedTeam = teamWorkspaceService.getCachedTeam();
    if (cachedTeam != null && mounted) {
      setState(() {
        _team = cachedTeam;
        _teams = [cachedTeam];
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _shareLocalDataWithTeam(cachedTeam);
      });
    } else {
      setState(() => _isLoading = true);
    }

    final teams = await teamWorkspaceService.getMyTeams();
    final selectedTeam = teams.isEmpty
        ? null
        : teams.firstWhere(
            (team) => team.id == cachedTeam?.id,
            orElse: () => teams.first,
          );

    if (!mounted) return;
    setState(() {
      _team = selectedTeam;
      _teams = teams;
      _isLoading = false;
    });

    if (selectedTeam != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _shareLocalDataWithTeam(selectedTeam);
      });
    }
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
      _closeTeamFormSheetIfOpen();
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
      _closeTeamFormSheetIfOpen();
      showSnackBar(context, text: 'تم الانضمام للفريق');
    });
  }

  Future<void> _leaveTeam() async {
    final team = _team;
    if (team == null) return;

    await _runSubmittingAction(() async {
      await teamWorkspaceService.leaveTeam(team.id);
      if (!mounted) return;
      final remainingTeams = _teams
          .where((item) => item.id != team.id)
          .toList();
      final nextTeam = remainingTeams.isEmpty ? null : remainingTeams.first;
      if (nextTeam != null) {
        await teamWorkspaceService.setCurrentTeam(nextTeam);
      }
      if (!mounted) return;
      setState(() {
        _teams = remainingTeams;
        _team = nextTeam;
      });
      showSnackBar(context, text: 'تم الخروج من الفريق');
    });
  }

  Future<void> _setTeamAndRefresh(TeamWorkspaceModel team) async {
    if (!mounted) return;
    await teamWorkspaceService.setCurrentTeam(team);
    setState(() {
      _team = team;
      _teams = [team, ..._teams.where((item) => item.id != team.id)];
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shareLocalDataWithTeam(team);
    });
  }

  Future<void> _selectTeam(TeamWorkspaceModel team) async {
    await teamWorkspaceService.setCurrentTeam(team);
    if (!mounted) return;
    setState(() => _team = team);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shareLocalDataWithTeam(team);
    });
  }

  Future<void> _openTeamFormSheet() async {
    _isTeamFormSheetOpen = true;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
        final bottomSafeArea = MediaQuery.paddingOf(context).bottom;
        return FractionallySizedBox(
          heightFactor: 0.78,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              bottomInset + bottomSafeArea + 16,
            ),
            child: SingleChildScrollView(child: _buildJoinOrCreateView()),
          ),
        );
      },
    );
    _isTeamFormSheetOpen = false;
  }

  void _closeTeamFormSheetIfOpen() {
    if (!_isTeamFormSheetOpen || !Navigator.of(context).canPop()) return;
    Navigator.of(context).pop();
    _isTeamFormSheetOpen = false;
  }

  Future<void> _shareLocalDataWithTeam(TeamWorkspaceModel team) async {
    try {
      final games = preparationListService.getGames();
      for (final game in games) {
        await teamWorkspaceService.addTeamPreparationGame(
          teamId: team.id,
          game: game,
        );
      }

      final history = serviceHistoryService.getCachedHistory();
      for (final item in history) {
        await teamWorkspaceService.addTeamHistory(
          teamId: team.id,
          history: item,
        );
      }
    } catch (_) {}
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
        if (_teams.length > 1) ...[
          _buildTeamsSwitcher(team),
          verticalSpace(14),
        ],
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
        _TeamFeatureCard(
          icon: Icons.add_business_rounded,
          title: 'فريق آخر',
          subtitle: 'إنشاء فريق جديد أو الانضمام بكود دعوة',
          onTap: _openTeamFormSheet,
        ),
        verticalSpace(14),
        _TeamFeatureCard(
          icon: Icons.people_alt_rounded,
          title: 'أعضاء الفريق',
          subtitle: 'عرض الأعضاء وإدارة الخروج أو الحذف',
          onTap: () =>
              context.pushNamed(Routes.teamMembersView, arguments: team),
        ),
        verticalSpace(14),
        _TeamFeatureCard(
          icon: Icons.checklist_rounded,
          title: 'تحضير الفريق',
          subtitle: 'الألعاب والأدوات المشتركة للفريق',
          onTap: () =>
              context.pushNamed(Routes.teamPreparationView, arguments: team),
        ),
        verticalSpace(14),
        _TeamFeatureCard(
          icon: Icons.history_rounded,
          title: 'خدمات الفريق',
          subtitle: 'الخدمات القديمة المشتركة بين أعضاء الفريق',
          onTap: () =>
              context.pushNamed(Routes.teamServiceHistoryView, arguments: team),
        ),
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

  Widget _buildTeamsSwitcher(TeamWorkspaceModel selectedTeam) {
    return _SectionBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('فرقي', style: TextStyles.bold19),
          verticalSpace(10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _teams.map((team) {
              final selected = team.id == selectedTeam.id;
              return ChoiceChip(
                selected: selected,
                label: Text(team.name),
                selectedColor: AppColors.secondaryColor.withValues(alpha: 0.35),
                checkmarkColor: AppColors.primaryColor,
                labelStyle: TextStyles.semiBold13.copyWith(
                  color: selected
                      ? AppColors.primaryColor
                      : Theme.of(context).colorScheme.onSurface,
                ),
                onSelected: (_) => _selectTeam(team),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TeamFeatureCard extends StatelessWidget {
  const _TeamFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SectionBox(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryColor),
              ),
              horizontalSpace(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyles.bold16),
                    verticalSpace(4),
                    Text(
                      subtitle,
                      style: TextStyles.regular13.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppColors.primaryColor,
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
