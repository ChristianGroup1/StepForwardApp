import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/features/home/data/brothers_cubit/brothers_cubit.dart';
import 'package:stepforward/features/home/presentation/views/widgets/asking_for_user_id_widget.dart';
import 'package:stepforward/features/home/presentation/views/widgets/get_brothers_section.dart';
import 'package:stepforward/features/home/presentation/views/widgets/waiting_for_approval_widget.dart';

class BrothersViewBody extends StatelessWidget {
  const BrothersViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<BrothersCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kHorizontalPadding - 6,
        vertical: kVerticalPadding,
      ),
      child: getUserData().frontId != null && getUserData().backId != null
          ? getUserData().isApproved
                ? GetBrothersSection(cubit: cubit)
                : const WaitingForApprovalWidget()
          : const AskingForUserIdWidget(),
    );
  }
}


