import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/repos/image_repo.dart';
import 'package:stepforward/core/services/get_it_service.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/custom_snak_bar.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_animated_loading_widget.dart';
import 'package:stepforward/core/widgets/custom_button.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/auth/presentation/views/widgets/image_field.dart';
import 'package:stepforward/features/home/data/brothers_cubit/brothers_cubit.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';

class UploadUserIdView extends StatelessWidget {
  const UploadUserIdView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BrothersCubit(
        getIt.get<HomeRepo>(),
        getIt.get<AuthRepo>(),
        getIt.get<ImagesRepo>(),
      ),
      child: Scaffold(
        body: BlocConsumer<BrothersCubit, BrothersState>(
          listener: (context, state) {
            if (state is AddUserIdsSuccessState) {
              context.pushNamedAndRemoveUntil(
                Routes.mainView,
                predicate: (route) => false,
              );
            } else if (state is AddUserIdsFailureState) {
              showSnackBar(context, text: state.errorMessage);
            }
          },
          builder: (context, state) {
            final isEn = context.isEn;
            return ModalProgressHUD(
              inAsyncCall: state is AddUserIdsLoadingState,
              progressIndicator: const CustomAnimatedLoadingWidget(),
              blur: 1.5,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kHorizontalPadding,
                      vertical: kVerticalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: const Icon(Icons.arrow_back_ios),
                            ),
                            Text(
                              isEn ? 'Upload ID Photo' : 'رفع صورة البطاقة',
                              style: TextStyles.bold23,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        verticalSpace(12),
                        Text(
                          isEn
                              ? 'This step is to protect servant data'
                              : 'هذا الاجراء بهدف الحفاظ على بيانات الخدام',
                          style: TextStyles.bold16,
                        ),
                        verticalSpace(64),
                        ImageField(
                          onChanged: (value) {
                            context.read<BrothersCubit>().frontId = value;
                          },
                          text: isEn ? 'Front of ID' : 'وجه البطاقة',
                        ),
                        verticalSpace(32),
                        ImageField(
                          onChanged: (value) {
                            context.read<BrothersCubit>().backId = value;
                          },
                          text: isEn ? 'Back of ID' : 'ظهر البطاقة',
                        ),
                        verticalSpace(32),
                        CustomButton(
                          text: isEn ? 'Upload ID' : 'رفع البطاقة',
                          onPressed: () {
                            if (context.read<BrothersCubit>().frontId != null &&
                                context.read<BrothersCubit>().backId != null) {
                              context.read<BrothersCubit>().addUserIds();
                            } else {
                              showSnackBar(
                                context,
                                text: isEn
                                    ? 'Please upload both sides of your ID'
                                    : 'يرجى رفع صورة البطاقة من الجهتين',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
