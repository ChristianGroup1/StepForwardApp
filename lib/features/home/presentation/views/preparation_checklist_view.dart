import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/services/preparation_list_service.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_app_bar.dart';
import 'package:stepforward/core/widgets/custom_empty_widget.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';

class PreparationChecklistView extends StatefulWidget {
  const PreparationChecklistView({super.key});

  @override
  State<PreparationChecklistView> createState() =>
      _PreparationChecklistViewState();
}

class _PreparationChecklistViewState extends State<PreparationChecklistView> {
  late List<GameModel> _games;
  late Set<String> _checkedTools;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _games = preparationListService.getGames();
    _checkedTools = preparationListService.getCheckedTools();
  }

  Future<void> _clearList() async {
    await preparationListService.clearGames();
    if (!mounted) return;
    setState(_loadData);
  }

  Future<void> _toggleTool(String toolKey, bool checked) async {
    setState(() {
      if (checked) {
        _checkedTools.add(toolKey);
      } else {
        _checkedTools.remove(toolKey);
      }
    });

    await preparationListService.setToolChecked(
      toolKey: toolKey,
      checked: checked,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;

    return Scaffold(
      appBar: buildAppBar(
        context,
        title: isEn ? 'Preparation List' : 'قائمة التحضير',
        onTap: () => context.pop(),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_games.isNotEmpty)
            IconButton(
              tooltip: isEn ? 'Clear list' : 'مسح القائمة',
              onPressed: _clearList,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kHorizontalPadding,
          vertical: kVerticalPadding,
        ),
        child: _games.isEmpty
            ? CustomEmptyWidget(
                title: isEn ? 'No games selected' : 'لا توجد ألعاب مختارة',
                subtitle: isEn
                    ? 'Open a game and add it to preparation.'
                    : 'افتح أي لعبة واضغط أضف للتحضير.',
              )
            : ListView.separated(
                itemCount: _games.length,
                separatorBuilder: (_, __) => verticalSpace(14),
                itemBuilder: (context, index) {
                  final game = _games[index];
                  final tools = _extractTools(game.tools);
                  return _GamePreparationCard(
                    game: game,
                    tools: tools,
                    checkedTools: _checkedTools,
                    onToggleTool: _toggleTool,
                    onRemove: () async {
                      await preparationListService.removeGame(game.id);
                      if (!mounted) return;
                      setState(_loadData);
                    },
                  );
                },
              ),
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

class _GamePreparationCard extends StatelessWidget {
  const _GamePreparationCard({
    required this.game,
    required this.tools,
    required this.checkedTools,
    required this.onToggleTool,
    required this.onRemove,
  });

  final GameModel game;
  final List<String> tools;
  final Set<String> checkedTools;
  final Future<void> Function(String toolKey, bool checked) onToggleTool;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
              IconButton(
                tooltip: isEn ? 'Remove game' : 'إزالة اللعبة',
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          verticalSpace(8),
          if (tools.isEmpty)
            Text(
              isEn ? 'No tools listed for this game.' : 'لا توجد أدوات مسجلة.',
              style: TextStyles.regular14,
            )
          else
            ...tools.map((tool) {
              final toolKey = '${game.id}::$tool';
              final checked = checkedTools.contains(toolKey);
              return CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: checked,
                activeColor: AppColors.primaryColor,
                onChanged: (value) => onToggleTool(toolKey, value ?? false),
                title: Text(tool, style: TextStyles.regular14),
              );
            }),
        ],
      ),
    );
  }
}
