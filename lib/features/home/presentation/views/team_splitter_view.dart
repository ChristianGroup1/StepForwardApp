import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_app_bar.dart';
import 'package:stepforward/core/widgets/custom_text_field.dart';

class TeamSplitterView extends StatefulWidget {
  const TeamSplitterView({super.key});

  @override
  State<TeamSplitterView> createState() => _TeamSplitterViewState();
}

class _TeamSplitterViewState extends State<TeamSplitterView> {
  final _childrenCountController = TextEditingController();
  final _teamsCountController = TextEditingController();
  final _childrenNamesController = TextEditingController();
  final _teamsImageKey = GlobalKey();
  final _random = Random();
  List<_GeneratedTeam> _teams = [];
  bool _isSavingImage = false;

  static const _arabicTeamNames = [
    'النور',
    'الرجاء',
    'السلام',
    'الفرح',
    'الإيمان',
    'المحبة',
    'القوة',
    'الحكمة',
    'النعمة',
    'الحق',
    'الكرمة',
    'الصخرة',
  ];

  static const _englishTeamNames = [
    'Light',
    'Hope',
    'Peace',
    'Joy',
    'Faith',
    'Love',
    'Power',
    'Wisdom',
    'Grace',
    'Truth',
    'Vine',
    'Rock',
  ];

  @override
  void dispose() {
    _childrenCountController.dispose();
    _teamsCountController.dispose();
    _childrenNamesController.dispose();
    super.dispose();
  }

  void _splitTeams() {
    final isEn = context.isEn;
    final enteredChildren = _extractChildren();
    final typedChildrenCount = int.tryParse(_childrenCountController.text) ?? 0;
    final childrenCount = enteredChildren.isNotEmpty
        ? enteredChildren.length
        : typedChildrenCount;
    final teamsCount = int.tryParse(_teamsCountController.text) ?? 0;

    if (childrenCount <= 0 || teamsCount <= 0) {
      _showMessage(
        isEn
            ? 'Enter child names or a valid children count'
            : 'اكتب أسماء الأولاد أو عدد أولاد صحيح',
      );
      return;
    }

    if (teamsCount > childrenCount) {
      _showMessage(
        isEn
            ? 'Teams cannot be more than children'
            : 'عدد الفرق لا يمكن أن يكون أكبر من عدد الأولاد',
      );
      return;
    }

    final children = enteredChildren.isNotEmpty
        ? List<_ChildEntry>.from(enteredChildren)
        : List<_ChildEntry>.generate(
            childrenCount,
            (index) => _ChildEntry(
              name: isEn ? 'Child ${index + 1}' : 'ولد ${index + 1}',
            ),
          );
    if (enteredChildren.any((child) => child.stage != null)) {
      children.sort((a, b) {
        final stageComparison = (a.stage ?? '').compareTo(b.stage ?? '');
        if (stageComparison != 0) return stageComparison;
        return a.name.compareTo(b.name);
      });
    } else {
      children.shuffle(_random);
    }
    final names = List<String>.from(isEn ? _englishTeamNames : _arabicTeamNames)
      ..shuffle(_random);

    final generatedTeams = List.generate(teamsCount, (index) {
      final fallbackName = isEn ? 'Team ${index + 1}' : 'فريق ${index + 1}';
      return _GeneratedTeam(
        name: index < names.length ? names[index] : fallbackName,
        members: <_ChildEntry>[],
      );
    });

    for (var index = 0; index < children.length; index++) {
      final sortedTeams = List<_GeneratedTeam>.from(generatedTeams)
        ..sort((a, b) {
          final memberComparison = a.members.length.compareTo(b.members.length);
          if (memberComparison != 0) return memberComparison;
          return a.stageBalanceScore.compareTo(b.stageBalanceScore);
        });
      sortedTeams.first.members.add(children[index]);
    }

    setState(() => _teams = generatedTeams);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<File?> _captureTeamsImage() async {
    final boundary =
        _teamsImageKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData?.buffer.asUint8List();
    if (bytes == null) return null;

    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'step_forward_teams_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${directory.path}/$fileName');
    return file.writeAsBytes(bytes);
  }

  Future<void> _saveTeamsImage() async {
    final isEn = context.isEn;
    if (_teams.isEmpty || _isSavingImage) return;

    setState(() => _isSavingImage = true);
    try {
      final file = await _captureTeamsImage();
      if (!mounted) return;

      if (file == null) {
        _showMessage(isEn ? 'Could not save image' : 'تعذر حفظ الصورة');
      } else {
        _showMessage(isEn ? 'Image saved' : 'تم حفظ الصورة');
      }
    } catch (_) {
      if (mounted) {
        _showMessage(isEn ? 'Could not save image' : 'تعذر حفظ الصورة');
      }
    } finally {
      if (mounted) setState(() => _isSavingImage = false);
    }
  }

  Future<void> _shareTeamsImage() async {
    final isEn = context.isEn;
    if (_teams.isEmpty || _isSavingImage) return;

    setState(() => _isSavingImage = true);
    try {
      final file = await _captureTeamsImage();
      if (!mounted) return;

      if (file == null) {
        _showMessage(isEn ? 'Could not create image' : 'تعذر إنشاء الصورة');
      } else {
        await Share.shareXFiles([
          XFile(file.path),
        ], text: isEn ? 'Generated teams' : 'الفرق المقسمة');
      }
    } catch (_) {
      if (mounted) {
        _showMessage(isEn ? 'Could not share image' : 'تعذر مشاركة الصورة');
      }
    } finally {
      if (mounted) setState(() => _isSavingImage = false);
    }
  }

  List<_ChildEntry> _extractChildren() {
    final seenNames = <String>{};
    final entries = _childrenNamesController.text
        .split(RegExp(r'\n+'))
        .map(_parseChildEntry)
        .whereType<_ChildEntry>()
        .where((child) {
          final normalizedName = child.name.trim().toLowerCase();
          if (seenNames.contains(normalizedName)) return false;
          seenNames.add(normalizedName);
          return true;
        })
        .toList();

    return entries;
  }

  _ChildEntry? _parseChildEntry(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final match = RegExp(
      r'^(.+?)(?:\s*[-:|،,]\s*|\s{2,})(.+)$',
    ).firstMatch(trimmed);
    if (match == null) return _ChildEntry(name: trimmed);

    final name = match.group(1)?.trim() ?? '';
    final stage = match.group(2)?.trim();
    if (name.isEmpty) return null;

    return _ChildEntry(
      name: name,
      stage: stage == null || stage.isEmpty ? null : stage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;

    return Scaffold(
      appBar: buildAppBar(
        context,
        title: isEn ? 'Team Splitter' : 'تقسيم المجموعات',
        onTap: () => context.pop(),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: kHorizontalPadding,
          vertical: kVerticalPadding,
        ),
        children: [
          Text(
            isEn
                ? 'Enter each child with their school stage, then split balanced teams. If names are empty, the app will use the children count.'
                : 'اكتب كل ولد ومعاه المرحلة، وسيتم تقسيم الفرق بشكل متوازن. لو الأسماء فاضية، التطبيق هيستخدم عدد الأولاد.',
            style: TextStyles.regular16,
          ),
          verticalSpace(16),
          CustomTextFormField(
            controller: _childrenNamesController,
            labelText: isEn ? 'Children names' : 'أسماء الأولاد',
            hintText: isEn
                ? 'One child per line\nExample:\nJohn  Grade 7\nMark  Grade 8'
                : 'كل ولد في سطر\nمثال:\nمينا  أولى إعدادي\nكيرلس  تانية إعدادي\nمارك  أولى إعدادي',
            textInputType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            minLines: 5,
            maxLines: 5,
            needsValidation: false,
          ),
          verticalSpace(12),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: _childrenCountController,
                  labelText: isEn ? 'Children count' : 'عدد الأولاد',
                  hintText: '20',
                  textInputType: TextInputType.number,
                  needsValidation: false,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              horizontalSpace(12),
              Expanded(
                child: CustomTextFormField(
                  controller: _teamsCountController,
                  labelText: isEn ? 'Teams' : 'عدد الفرق',
                  hintText: '4',
                  textInputType: TextInputType.number,
                  needsValidation: false,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          verticalSpace(16),
          FilledButton.icon(
            onPressed: _splitTeams,
            icon: const Icon(Icons.shuffle_rounded),
            label: Text(
              _teams.isEmpty
                  ? (isEn ? 'Split teams' : 'قسّم الفرق')
                  : (isEn ? 'Shuffle again' : 'إعادة التقسيم'),
            ),
          ),
          if (_teams.isNotEmpty) ...[
            verticalSpace(22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    isEn ? 'Generated Teams' : 'الفرق المقسمة',
                    style: TextStyles.bold19.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: isEn ? 'Save image' : 'حفظ كصورة',
                  onPressed: _isSavingImage ? null : _saveTeamsImage,
                  icon: const Icon(Icons.download_rounded),
                ),
                IconButton(
                  tooltip: isEn ? 'Share image' : 'مشاركة الصورة',
                  onPressed: _isSavingImage ? null : _shareTeamsImage,
                  icon: const Icon(Icons.share_outlined),
                ),
              ],
            ),
            verticalSpace(12),
            RepaintBoundary(
              key: _teamsImageKey,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [..._teams.map((team) => _TeamCard(team: team))],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.team});

  final _GeneratedTeam team;

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
            children: [
              const Icon(Icons.groups_rounded, color: AppColors.primaryColor),
              horizontalSpace(8),
              Expanded(
                child: Text(
                  team.name,
                  style: TextStyles.bold16.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              Text(
                isEn
                    ? '${team.members.length} members'
                    : '${team.members.length} أفراد',
                style: TextStyles.semiBold13.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          verticalSpace(10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: team.members.map((member) {
              return Chip(
                label: Text(
                  member.stage == null
                      ? member.name
                      : (isEn
                            ? '${member.name} (${member.stage})'
                            : '${member.name} (${member.stage})'),
                ),
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.08),
                side: BorderSide(
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _GeneratedTeam {
  const _GeneratedTeam({required this.name, required this.members});

  final String name;
  final List<_ChildEntry> members;

  int get stageBalanceScore {
    return members.map((child) => child.stage ?? '').toSet().length;
  }
}

class _ChildEntry {
  const _ChildEntry({required this.name, this.stage});

  final String name;
  final String? stage;
}
