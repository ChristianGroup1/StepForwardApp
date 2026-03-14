import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/utils/custom_snak_bar.dart';
import 'package:stepforward/core/widgets/custom_app_bar.dart';

class PdfViewerScreen extends StatelessWidget {
  final String url;
  final String title;

  const PdfViewerScreen({super.key, required this.url, required this.title});

  Future<void> downloadPDF(BuildContext context) async {
    final isEn = context.isEn;
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      final fileName = '${title.replaceAll(" ", "_")}.pdf';
      final filePath = '${directory.path}/$fileName';
      await Dio().download(url, filePath);
      showSnackBar(
        context,
        text: isEn ? 'Downloaded successfully' : 'تم التحميل بنجاح',
        color: Colors.green,
      );
    } catch (e) {
      showSnackBar(
        context,
        text: isEn ? 'Error during download' : 'حدث خطأ اثناء التحميل',
        color: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context,
        title: title,
        onTap: () => context.pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => downloadPDF(context),
          ),
        ],
      ),
      body: const PDF(autoSpacing: false, pageFling: false).cachedFromUrl(url),
    );
  }
}
