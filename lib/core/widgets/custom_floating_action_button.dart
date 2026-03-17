import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_images.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/features/home/presentation/views/chatbot_view.dart';

class ChatBotFloatingButton extends StatefulWidget {
  const ChatBotFloatingButton({super.key});

  @override
  State<ChatBotFloatingButton> createState() => _ChatBotFloatingButtonState();
}

class _ChatBotFloatingButtonState extends State<ChatBotFloatingButton> {
  bool _showMessage = false;
  double _opacity = 0;
  Offset _slideOffset = const Offset(0, 0.2);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showMessage = true;
          _opacity = 1;
          _slideOffset = Offset.zero;
        });
      }
    });
  }

  void _dismissMessage() {
    setState(() {
      _opacity = 0;
      _slideOffset = const Offset(0, 0.2);
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showMessage = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2, right: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: []),
    );
  }
}
