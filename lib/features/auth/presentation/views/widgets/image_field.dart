import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';

class ImageField extends StatefulWidget {
  final ValueChanged<File?> onChanged;
  final String text;
  const ImageField({super.key, required this.onChanged, required this.text});

  @override
  State<ImageField> createState() => _ImageFieldState();
}

class _ImageFieldState extends State<ImageField> {
  bool isLoading = false;
  File? fileImage;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          isLoading = true;
        });
        try {
          await pickImage();
        } catch (e) {
          setState(() {
            isLoading = false;
          });
        }
        setState(() {
          isLoading = false;
        });
        // Pick an image
      },
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey, width: 0.5),
            ),
            child: fileImage != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                      fileImage!,
                      fit: BoxFit.cover,
                    ),
                )
                : Column(
                  children: [
                    const Icon(
                        Icons.image_outlined,
                        size: 180,
                        color: AppColors.lightPrimaryColor,
                      ),
                      Text(widget.text, style: TextStyles.bold13,)
                  ],
                ),
          ),
          Visibility(
          visible: fileImage != null,
            child: IconButton(onPressed: (){
            setState(() {
              fileImage = null;
               widget.onChanged(fileImage);
            });
          }, icon: const CircleAvatar(child: Icon(Icons.close),)))
        ],
      ),
    );
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    fileImage = File(image!.path);
    widget.onChanged(fileImage!);
  }
}