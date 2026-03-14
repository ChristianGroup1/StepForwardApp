import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/services/openai_translation_service.dart';

/// A [Text]-like widget that displays [text] as-is in Arabic mode.
/// In English mode it shows the original text immediately, then replaces it
/// with the translated version once the (cached) translation completes.
class TranslatingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatingText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<TranslatingText> createState() => _TranslatingTextState();
}

class _TranslatingTextState extends State<TranslatingText> {
  String _display = '';
  bool _isEn = false;

  @override
  void initState() {
    super.initState();
    _display = widget.text;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nowEn = context.isEn;
    if (nowEn != _isEn) {
      _isEn = nowEn;
      if (nowEn) {
        _translate();
      } else {
        setState(() => _display = widget.text);
      }
    }
  }

  @override
  void didUpdateWidget(covariant TranslatingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _display = widget.text;
      if (_isEn) _translate();
    }
  }

  Future<void> _translate() async {
    final translated =
        await OpenAiTranslationService.translateToEnglish(widget.text);
    if (mounted && _isEn) {
      setState(() => _display = translated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _display,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
