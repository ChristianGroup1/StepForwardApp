import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/services/preparation_list_service.dart';
import 'package:stepforward/core/services/team_workspace_service.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
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
      // Keep the page usable with local preparation even if Firestore rules
      // reject the team sync.
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
          final teamGames = snapshot.data ?? [];
          final localGames = preparationListService.getGames();
          final games = _mergeGames(teamGames, localGames);

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
              else if (snapshot.hasError && localGames.isEmpty)
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

  List<GameModel> _mergeGames(
    List<GameModel> teamGames,
    List<GameModel> localGames,
  ) {
    final byId = <String, GameModel>{};

    for (final game in teamGames) {
      if (game.id.isNotEmpty) byId[game.id] = game;
    }

    for (final game in localGames) {
      if (game.id.isNotEmpty) byId.putIfAbsent(game.id, () => game);
    }

    return byId.values.toList();
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.sports_esports_rounded,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  game.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.bold16.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              _ToolsCountBadge(count: tools.length),
            ],
          ),
          const SizedBox(height: 10),
          if (tools.isEmpty)
            const Text('لا توجد أدوات مسجلة.', style: TextStyles.regular14)
          else ...[
            ...tools.take(3).map((tool) => _ToolPreviewRow(tool: tool)),
            if (tools.length > 3) ...[
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => _showAllTools(context, tools),
                  icon: const Icon(Icons.list_alt_rounded, size: 18),
                  label: Text('عرض كل الأدوات (${tools.length})'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _showAllTools(BuildContext context, List<String> tools) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        final bottomSafeArea = MediaQuery.paddingOf(context).bottom;
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomSafeArea + 16),
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
                const SizedBox(height: 14),
                Text(game.name, style: TextStyles.bold19),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: tools.length,
                    separatorBuilder: (_, __) => const Divider(height: 12),
                    itemBuilder: (context, index) {
                      return _ToolPreviewRow(tool: tools[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

class _ToolsCountBadge extends StatelessWidget {
  const _ToolsCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          '$count أدوات',
          style: TextStyles.semiBold11.copyWith(color: AppColors.primaryColor),
        ),
      ),
    );
  }
}

class _ToolPreviewRow extends StatelessWidget {
  const _ToolPreviewRow({required this.tool});

  final String tool;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          color: AppColors.primaryColor,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(tool, style: TextStyles.regular14)),
      ],
    );
  }
}
