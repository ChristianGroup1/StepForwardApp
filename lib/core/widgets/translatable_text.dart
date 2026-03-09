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

  /// Version counter used to discard stale async results when locale or
  /// text changes while a translation is already in flight.
  int _version = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isEnglish = context.read<LanguageCubit>().isEnglish;
    _applyLanguage(isEnglish);
  }

  void _applyLanguage(bool isEnglish) {
    if (isEnglish && widget.text.trim().isNotEmpty) {
      // Only start a new translation if we don't already have one for this text.
      if (_translated == null && !_loading) {
        _translate();
      }
    } else if (!isEnglish) {
      _version++;
      if (_translated != null || _loading) {
        setState(() {
          _translated = null;
          _loading = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(TranslatableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      // Text changed – discard previous translation and retranslate.
      _version++;
      _translated = null;
      _loading = false;
      final isEnglish = context.read<LanguageCubit>().isEnglish;
      _applyLanguage(isEnglish);
    }
  }

  Future<void> _translate() async {
    final capturedVersion = ++_version;
    if (mounted) setState(() => _loading = true);
    final result =
        await OpenAITranslationService.translateToEnglish(widget.text);
    if (mounted && _version == capturedVersion) {
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
        _applyLanguage(locale.languageCode == 'en');
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
