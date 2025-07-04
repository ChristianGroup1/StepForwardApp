import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/services/get_it_service.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/widgets/custom_app_bar.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/home/data/home_cubit/home_cubit.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';
import 'package:stepforward/features/home/presentation/views/widgets/favorites_view_body.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeCubit(getIt.get<HomeRepo>(), getIt.get<AuthRepo>())..fetchUserFavorites(),
      child: Scaffold(
        appBar: buildAppBar(
          context,
          title: 'المفضلة',
          onTap: () => context.pop(),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kHorizontalPadding,
            vertical: kVerticalPadding,
          ),
          child: FavoritesViewBody(),
        ),
      ),
    );
  }
}
