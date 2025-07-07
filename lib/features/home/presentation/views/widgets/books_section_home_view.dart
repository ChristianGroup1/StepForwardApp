import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/features/home/data/games_cubit/games_cubit.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_home_view_item.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_loading_home_view_item.dart';

class BooksSectionHomeView extends StatelessWidget {
  const BooksSectionHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('كتب ومقالات', style: TextStyles.bold16),
          verticalSpace(12),
          BlocBuilder<GamesCubit, GamesState>(
            buildWhen: (previous, current) =>
                current is GetBooksSuccessState ||
                current is GetBooksFailureState ||
                current is GetBooksLoadingState,
            builder: (context, state) {
              if (state is GetBooksSuccessState) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.21,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final book = state.books[index];
                      return GestureDetector(
                        onTap: () {
                          context.pushNamed(
                            Routes.pdfViewerScreen,
                            arguments: {'url': book.url, 'title': book.name},
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 16,
                          ),
                          child: CustomHomeViewItem(
                            imageUrl: book.coverUrl!,
                            name: book.name,
                          ),
                        ),
                      );
                    },

                    itemCount: state.books.length,
                  ),
                );
              } else if (state is GetBooksLoadingState) {
                return const CustomLoadingHomeViewItem();
              } else if (state is GetBooksFailureState) {
                return Center(
                  child: Text(
                    'حدث خطاء اثناء تحميل العاب',
                    style: TextStyles.regular16.copyWith(color: Colors.red),
                  ),
                );
              } else {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
            },
          ),
        ],
      ),
    );
  }
}
