import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/cubits/language_cubit.dart';
import 'package:stepforward/core/services/openai_translation_service.dart';

/// A widget that displays [text] and automatically translates it to English
/// via the OpenAI API when the app language is set to English.
///
/// Translations are cached in-memory so the same text is only sent to the API
/// once per app session.
class TranslatableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatableText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  State<TranslatableText> createState() => _TranslatableTextState();
}

class _TranslatableTextState extends State<TranslatableText> {
  String? _translated;
  bool _loading = false;
  String? _lastText;
  bool _lastIsEnglish = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isEnglish = context.read<LanguageCubit>().isEnglish;
    if (isEnglish != _lastIsEnglish || widget.text != _lastText) {
      _lastIsEnglish = isEnglish;
      _lastText = widget.text;
      if (isEnglish && widget.text.trim().isNotEmpty) {
        _translate();
      } else {
        _translated = null;
        _loading = false;
      }
    }
  }

  Future<void> _translate() async {
    if (mounted) setState(() => _loading = true);
    final result =
        await OpenAITranslationService.translateToEnglish(widget.text);
    if (mounted) {
      setState(() {
        _translated = result;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LanguageCubit, Locale>(
      listener: (context, locale) {
        final isEnglish = locale.languageCode == 'en';
        _lastIsEnglish = isEnglish;
        if (isEnglish && widget.text.trim().isNotEmpty) {
          _translate();
        } else {
          setState(() {
            _translated = null;
            _loading = false;
          });
        }
      },
      child: _loading
          ? SizedBox(
              height: (widget.style?.fontSize ?? 14) + 4,
              width: 80,
              child: const LinearProgressIndicator(minHeight: 2),
            )
          : Text(
              _translated ?? widget.text,
              style: widget.style,
              maxLines: widget.maxLines,
              overflow: widget.overflow,
            ),
    );
  }
}
