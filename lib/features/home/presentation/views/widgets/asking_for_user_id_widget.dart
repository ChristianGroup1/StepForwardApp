import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/widgets/custom_button.dart';

class AskingForUserIdWidget extends StatelessWidget {
  const AskingForUserIdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.perm_identity, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'لم يتم إضافة الهوية الخاصة بك',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'الرجاء رفع صورة الهوية الأمامية والخلفية حتى تتمكن من استخدام جميع الميزات.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'رفع',
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
