import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/widgets/custom_button.dart';

class AskingForUserIdWidget extends StatelessWidget {
  const AskingForUserIdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.perm_identity, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              isEn ? 'Your ID has not been added' : 'لم يتم إضافة الهوية الخاصة بك',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isEn
                  ? 'Please upload a photo of your front and back ID to access all features.'
                  : 'الرجاء رفع صورة الهوية الأمامية والخلفية حتى تتمكن من استخدام جميع الميزات.',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: isEn ? 'Upload' : 'رفع',
              onPressed: () {
                context.pushNamed(Routes.uploadIdView);
              },
            ),
          ],
        ),
      ),
    );
  }
}
