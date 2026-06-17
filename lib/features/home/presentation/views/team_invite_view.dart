import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/services/team_workspace_service.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_app_bar.dart';
import 'package:stepforward/features/home/domain/models/team_workspace_model.dart';

class TeamInviteView extends StatefulWidget {
  const TeamInviteView({super.key, required this.inviteCode});

  final String inviteCode;

  @override
  State<TeamInviteView> createState() => _TeamInviteViewState();
}

class _TeamInviteViewState extends State<TeamInviteView> {
  TeamWorkspaceModel? _team;
  _TeamInviteState _state = _TeamInviteState.loading;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _handleInvite();
  }

  Future<void> _handleInvite() async {
    final code = teamWorkspaceService.normalizeInviteCode(widget.inviteCode);
    if (code.isEmpty) {
      setState(() {
        _state = _TeamInviteState.error;
        _message = 'رابط الدعوة غير صحيح';
      });
      return;
    }

    try {
      final currentTeams = await teamWorkspaceService.getMyTeams();
      final existingTeam = _findTeamByCode(currentTeams, code);
      if (existingTeam != null) {
        await teamWorkspaceService.setCurrentTeam(existingTeam);
        if (!mounted) return;
        setState(() {
          _team = existingTeam;
          _state = _TeamInviteState.alreadyMember;
          _message = 'أنت عضو بالفعل في هذا الفريق';
        });
        return;
      }

      final joinedTeam = await teamWorkspaceService.joinTeamByInviteCode(code);
      if (!mounted) return;

      if (joinedTeam == null) {
        setState(() {
          _state = _TeamInviteState.error;
          _message = 'كود الدعوة غير صحيح';
        });
        return;
      }

      setState(() {
        _team = joinedTeam;
        _state = _TeamInviteState.joined;
        _message = 'تم الانضمام للفريق';
      });
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _state = _TeamInviteState.error;
        _message = _firebaseErrorMessage(error);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _state = _TeamInviteState.error;
        _message = 'حدث خطأ أثناء فتح الدعوة';
      });
    }
  }

  TeamWorkspaceModel? _findTeamByCode(
    List<TeamWorkspaceModel> teams,
    String code,
  ) {
    for (final team in teams) {
      if (team.id == code || team.inviteCode == code) return team;
    }
    return null;
  }

  String _firebaseErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Firebase رفض الانضمام. راجع صلاحيات teams في Firestore Rules';
      case 'not-found':
        return 'كود الدعوة غير صحيح';
      case 'unauthenticated':
        return 'لازم تعمل تسجيل دخول قبل الانضمام للفريق';
      case 'unavailable':
        return 'Firebase غير متاح الآن، راجع الاتصال وحاول مرة أخرى';
      default:
        return 'Firebase error: ${error.code}';
    }
  }

  void _openTeam() {
    final navigator = Navigator.of(context);
    navigator.pushNamedAndRemoveUntil(Routes.mainView, (_) => false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigator.pushNamed(
        Routes.teamWorkspaceView,
        arguments: _team?.inviteCode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;
    final team = _team;
    final isLoading = _state == _TeamInviteState.loading;
    final isSuccess =
        _state == _TeamInviteState.joined ||
        _state == _TeamInviteState.alreadyMember;

    return Scaffold(
      appBar: buildAppBar(
        context,
        title: context.isEn ? 'Team Invite' : 'دعوة الفريق',
        onTap: () => context.pop(),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            kHorizontalPadding,
            kVerticalPadding,
            kHorizontalPadding,
            kVerticalPadding + bottomSafeArea,
          ),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    isLoading
                        ? Icons.groups_rounded
                        : isSuccess
                        ? Icons.check_circle_rounded
                        : Icons.error_outline_rounded,
                    size: 56,
                    color: isSuccess
                        ? Colors.green
                        : isLoading
                        ? AppColors.primaryColor
                        : Colors.red,
                  ),
                  verticalSpace(14),
                  Text(
                    isLoading ? 'جاري فتح دعوة الفريق...' : _message,
                    textAlign: TextAlign.center,
                    style: TextStyles.bold19.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  if (team != null) ...[
                    verticalSpace(10),
                    Text(
                      team.name,
                      textAlign: TextAlign.center,
                      style: TextStyles.bold23,
                    ),
                    verticalSpace(6),
                    Text(
                      'كود الدعوة: ${team.inviteCode}',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyles.regular14,
                    ),
                  ],
                  verticalSpace(18),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (isSuccess)
                    FilledButton.icon(
                      onPressed: _openTeam,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('فتح الفريق'),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: _handleInvite,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('حاول مرة أخرى'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _TeamInviteState { loading, joined, alreadyMember, error }
