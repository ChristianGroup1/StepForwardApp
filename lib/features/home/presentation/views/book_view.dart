import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/widgets/custom_app_bar.dart';

class PdfViewerScreen extends StatelessWidget {
  final String url;
  final String title;

  const PdfViewerScreen({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title: title, onTap: () => context.pop()),

      body: PDF(autoSpacing: false, pageFling: false).cachedFromUrl(url),
    );
  }
}
