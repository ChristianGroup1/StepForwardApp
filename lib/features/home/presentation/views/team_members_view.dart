import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/services/team_workspace_service.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/custom_snak_bar.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_app_bar.dart';
import 'package:stepforward/core/widgets/custom_empty_widget.dart';
import 'package:stepforward/features/home/domain/models/team_workspace_model.dart';

class TeamMembersView extends StatefulWidget {
  const TeamMembersView({super.key, required this.team});

  final TeamWorkspaceModel team;

  @override
  State<TeamMembersView> createState() => _TeamMembersViewState();
}

class _TeamMembersViewState extends State<TeamMembersView> {
  late TeamWorkspaceModel _team = widget.team;
  List<TeamMemberModel> _members = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  bool _isSubmitting = false;
  late final String? _currentUserId = getCachedUserData()?.id;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      teamWorkspaceService.isCurrentUserAdmin(),
      teamWorkspaceService.getTeamMembers(_team),
    ]);

    if (!mounted) return;
    setState(() {
      _isAdmin = results[0] as bool;
      _members = results[1] as List<TeamMemberModel>;
      _isLoading = false;
    });
  }

  Future<void> _leaveTeam() async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;
    await _removeMember(currentUserId, isCurrentUser: true);
  }

  Future<void> _confirmRemoveMember(TeamMemberModel member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف عضو'),
          content: Text('هل تريد حذف ${member.displayName} من الفريق؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _removeMember(member.id);
    }
  }

  Future<void> _removeMember(
    String userId, {
    bool isCurrentUser = false,
  }) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      await teamWorkspaceService.removeTeamMember(
        teamId: _team.id,
        userId: userId,
      );
      if (!mounted) return;

      setState(() {
        _team = _team.copyWith(
          members: _team.members
              .where((memberId) => memberId != userId)
              .toList(),
        );
        _members.removeWhere((member) => member.id == userId);
      });

      showSnackBar(
        context,
        text: isCurrentUser ? 'تم الخروج من الفريق' : 'تم حذف العضو',
      );

      if (isCurrentUser && mounted) context.pop();
    } catch (_) {
      if (!mounted) return;
      showSnackBar(
        context,
        text: 'تعذر تنفيذ العملية. راجع صلاحيات الفريق.',
        color: Colors.red,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;
    final canLeave =
        _currentUserId != null && _team.members.contains(_currentUserId);

    return Scaffold(
      appBar: buildAppBar(
        context,
        title: 'أعضاء الفريق',
        onTap: () => context.pop(),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadMembers,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            kHorizontalPadding,
            kVerticalPadding,
            kHorizontalPadding,
            kVerticalPadding + bottomSafeArea + 24,
          ),
          children: [
            Text(
              '${_members.length} أعضاء',
              style: TextStyles.bold19.copyWith(color: AppColors.primaryColor),
            ),
            verticalSpace(12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_members.isEmpty)
              const CustomEmptyWidget(
                title: 'لا يوجد أعضاء',
                subtitle: 'لم يتم العثور على أعضاء في هذا الفريق.',
              )
            else
              ..._members.map(
                (member) => _TeamMemberCard(
                  member: member,
                  currentUserId: _currentUserId,
                  canRemove:
                      (_isAdmin || _team.ownerId == _currentUserId) &&
                      member.id != _currentUserId &&
                      !member.isOwner,
                  isSubmitting: _isSubmitting,
                  onRemove: () => _confirmRemoveMember(member),
                ),
              ),
            if (canLeave) ...[
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
          ],
        ),
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  const _TeamMemberCard({
    required this.member,
    required this.currentUserId,
    required this.canRemove,
    required this.isSubmitting,
    required this.onRemove,
  });

  final TeamMemberModel member;
  final String? currentUserId;
  final bool canRemove;
  final bool isSubmitting;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = member.id == currentUserId;

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
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
            foregroundColor: AppColors.primaryColor,
            child: Text(_initials(member.displayName)),
          ),
          horizontalSpace(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.displayName, style: TextStyles.bold16),
                if (member.email.isNotEmpty) ...[
                  verticalSpace(4),
                  Text(member.email, style: TextStyles.regular13),
                ],
                verticalSpace(6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (member.isOwner)
                      const _MemberBadge(label: 'مالك الفريق'),
                    if (member.isAdmin) const _MemberBadge(label: 'أدمن'),
                    if (isCurrentUser) const _MemberBadge(label: 'أنت'),
                    if (member.churchName.isNotEmpty)
                      _MemberBadge(label: member.churchName),
                  ],
                ),
              ],
            ),
          ),
          if (canRemove)
            IconButton(
              tooltip: 'حذف العضو',
              onPressed: isSubmitting ? null : onRemove,
              icon: const Icon(
                Icons.person_remove_alt_1_rounded,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first.characters.first;
    final second = parts.length > 1 && parts[1].isNotEmpty
        ? parts[1].characters.first
        : '';
    return '$first$second'.toUpperCase();
  }
}

class _MemberBadge extends StatelessWidget {
  const _MemberBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: TextStyles.semiBold11.copyWith(color: AppColors.primaryColor),
        ),
      ),
    );
  }
}
