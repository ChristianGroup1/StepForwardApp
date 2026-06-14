import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/services/recently_opened_service.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/features/home/domain/models/book_model.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_home_view_item.dart';

class RecentlyOpenedSectionHomeView extends StatefulWidget {
  const RecentlyOpenedSectionHomeView({super.key});

  @override
  State<RecentlyOpenedSectionHomeView> createState() =>
      _RecentlyOpenedSectionHomeViewState();
}

class _RecentlyOpenedSectionHomeViewState
    extends State<RecentlyOpenedSectionHomeView> {
  @override
  void initState() {
    super.initState();
    recentlyOpenedService.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;

    return SliverToBoxAdapter(
      child: ValueListenableBuilder<List<RecentlyOpenedItem>>(
        valueListenable: recentlyOpenedService.itemsNotifier,
        builder: (context, items, _) {
          if (items.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEn ? 'Recently Opened' : 'آخر ما تم فتحه',
                    style: TextStyles.bold16.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              verticalSpace(12),
              SizedBox(
                height: isDeviceInPortrait(context)
                    ? MediaQuery.sizeOf(context).height * 0.23
                    : MediaQuery.sizeOf(context).height * 0.56,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        top: 16,
                      ),
                      child: GestureDetector(
                        onTap: () => _openItem(context, item),
                        child: Column(
                          children: [
                            CustomHomeViewItem(
                              imageUrl: item.coverUrl,
                              name: item.name,
                            ),
                            verticalSpace(4),
                            _ItemTypeChip(type: item.type),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openItem(BuildContext context, RecentlyOpenedItem item) async {
    if (item.type == RecentlyOpenedItemType.game && item.game != null) {
      await recentlyOpenedService.addGame(item.game!);
      if (!context.mounted) return;
      context.pushNamed(Routes.gameDetails, arguments: item.game);
      return;
    }

    if (item.type == RecentlyOpenedItemType.book &&
        (item.bookUrl ?? '').isNotEmpty) {
      await recentlyOpenedService.addBook(
        BookModel(
          id: item.id,
          name: item.name,
          url: item.bookUrl ?? '',
          coverUrl: item.coverUrl,
        ),
      );
      if (!context.mounted) return;
      context.pushNamed(
        Routes.pdfViewerScreen,
        arguments: {'url': item.bookUrl, 'title': item.name},
      );
    }
  }
}

class _ItemTypeChip extends StatelessWidget {
  const _ItemTypeChip({required this.type});

  final RecentlyOpenedItemType type;

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;
    final label = type == RecentlyOpenedItemType.game
        ? (isEn ? 'Game' : 'لعبة')
        : (isEn ? 'Book' : 'كتاب');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: Text(
          label,
          style: TextStyles.semiBold11.copyWith(color: AppColors.primaryColor),
        ),
      ),
    );
  }
}
