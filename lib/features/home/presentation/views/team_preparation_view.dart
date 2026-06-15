import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/services/preparation_list_service.dart';
import 'package:stepforward/core/services/team_workspace_service.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/custom_snak_bar.dart';
import 'package:stepforward/core/widgets/custom_app_bar.dart';
import 'package:stepforward/core/widgets/custom_empty_widget.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/features/home/domain/models/team_workspace_model.dart';

class TeamPreparationView extends StatefulWidget {
  const TeamPreparationView({super.key, required this.team});

  final TeamWorkspaceModel team;

  @override
  State<TeamPreparationView> createState() => _TeamPreparationViewState();
}

class _TeamPreparationViewState extends State<TeamPreparationView> {
  @override
  void initState() {
    super.initState();
    _shareLocalPreparationWithTeam();
  }

  Future<void> _shareLocalPreparationWithTeam() async {
    final localGames = preparationListService.getGames();
    if (localGames.isEmpty) return;

    try {
      for (final game in localGames) {
        await teamWorkspaceService.addTeamPreparationGame(
          teamId: widget.team.id,
          game: game,
        );
      }
    } catch (_) {
      if (!mounted) return;
      showSnackBar(
        context,
        text: 'تعذر مشاركة التحضير مع الفريق. راجع صلاحيات Firebase.',
        color: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: buildAppBar(
        context,
        title: 'تحضير الفريق',
        onTap: () => context.pop(),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<GameModel>>(
        stream: teamWorkspaceService.watchTeamPreparationGames(widget.team.id),
        builder: (context, snapshot) {
          final games = snapshot.data ?? [];

          return ListView(
            padding: EdgeInsets.fromLTRB(
              kHorizontalPadding,
              kVerticalPadding,
              kHorizontalPadding,
              kVerticalPadding + bottomSafeArea + 24,
            ),
            children: [
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (snapshot.hasError)
                const CustomEmptyWidget(
                  title: 'تعذر تحميل التحضير',
                  subtitle: 'راجع صلاحيات الفريق أو الاتصال بالإنترنت.',
                )
              else if (games.isEmpty)
                const CustomEmptyWidget(
                  title: 'لا توجد قائمة تحضير للفريق',
                  subtitle: 'أي لعبة يضيفها عضو للتحضير ستظهر هنا تلقائيًا.',
                )
              else
                ...games.map((game) => _TeamPreparationGameCard(game: game)),
            ],
          );
        },
      ),
    );
  }
}

class _TeamPreparationGameCard extends StatelessWidget {
  const _TeamPreparationGameCard({required this.game});

  final GameModel game;

  @override
  Widget build(BuildContext context) {
    final tools = _extractTools(game.tools);

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
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        title: Text(
          game.name,
          style: TextStyles.bold16.copyWith(color: AppColors.primaryColor),
        ),
        subtitle: Text('${tools.length} أدوات', style: TextStyles.regular13),
        children: tools.isEmpty
            ? [
                const ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('لا توجد أدوات مسجلة.'),
                ),
              ]
            : tools
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
      ),
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
}
