import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/backend_endpoints.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';

class GameRatingSummaryChip extends StatefulWidget {
  const GameRatingSummaryChip({
    super.key,
    this.gameId,
    this.average = 0,
    this.count = 0,
    this.compact = false,
  });

  final String? gameId;
  final double average;
  final int count;
  final bool compact;

  @override
  State<GameRatingSummaryChip> createState() => _GameRatingSummaryChipState();
}

class _GameRatingSummaryChipState extends State<GameRatingSummaryChip> {
  late double _average = widget.average;
  late int _count = widget.count;

  @override
  void initState() {
    super.initState();
    _loadStatsIfNeeded();
  }

  @override
  void didUpdateWidget(covariant GameRatingSummaryChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.average != widget.average ||
        oldWidget.count != widget.count) {
      _average = widget.average;
      _count = widget.count;
    }
    if (oldWidget.gameId != widget.gameId) {
      _loadStatsIfNeeded();
    }
  }

  Future<void> _loadStatsIfNeeded() async {
    final gameId = widget.gameId;
    if (gameId == null || gameId.isEmpty) return;

    try {
      final gameDoc = await FirebaseFirestore.instance
          .collection(BackendEndpoints.getGames)
          .doc(gameId)
          .get();
      final data = gameDoc.data() ?? {};
      if (!mounted) return;
      setState(() {
        _average = _doubleFromJson(data['ratingAverage']);
        _count = _intFromJson(data['ratingCount']);
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_count <= 0) {
      return _RatingChipShell(
        compact: widget.compact,
        child: Text(
          'لم يتم التقييم',
          style: TextStyles.semiBold11.copyWith(color: AppColors.primaryColor),
        ),
      );
    }

    return _RatingChipShell(
      compact: widget.compact,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.secondaryColor,
            size: 17,
          ),
          horizontalSpace(3),
          Text(
            _average.toStringAsFixed(1),
            style: TextStyles.semiBold13.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          horizontalSpace(4),
          Text(
            '($_count)',
            style: TextStyles.regular11.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.62),
            ),
          ),
        ],
      ),
    );
  }

  int _intFromJson(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _doubleFromJson(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _RatingChipShell extends StatelessWidget {
  const _RatingChipShell({required this.child, required this.compact});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.secondaryColor.withValues(alpha: 0.32),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 5 : 6,
        ),
        child: child,
      ),
    );
  }
}
