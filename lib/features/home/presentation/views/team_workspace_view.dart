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
    if (team != null) {
      await _shareLocalDataWithTeam(team);
    }

    if (!mounted) return;
    setState(() {
      _team = team;
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
      setState(() => _team = null);
      showSnackBar(context, text: 'تم الخروج من الفريق');
    });
  }

  Future<void> _setTeamAndRefresh(TeamWorkspaceModel team) async {
    await _shareLocalDataWithTeam(team);
    if (!mounted) return;
    setState(() => _team = team);
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
