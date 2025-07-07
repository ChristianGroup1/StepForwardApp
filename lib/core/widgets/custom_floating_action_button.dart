import 'package:flutter/material.dart';
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
  Offset _slideOffset = const Offset(0, 0.2); // Start from below

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
      if (mounted) {
        setState(() {
          _showMessage = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatBotScreen()),
              );
            },
            child: CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.lightPrimaryColor,
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    Assets.assetsImagesStepforwardSplash,
                    fit: BoxFit.cover,
                    width: 48,
                    height: 48,
                  ),
                ),
              ),
            ),
          ),
          if (_showMessage)
            AnimatedSlide(
              duration: const Duration(milliseconds: 400),
              offset: _slideOffset,
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: _opacity,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _dismissMessage,
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      horizontalSpace(4),
                      Text(
                        'كيف يمكنني مساعدتك؟',
                        style: TextStyles.bold13.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
