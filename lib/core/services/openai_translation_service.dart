import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for translating Arabic content to English using OpenAI GPT.
///
/// Call [OpenAiTranslationService.configure] once at app startup with your
/// OpenAI secret key.  Pass the key via
/// `--dart-define=OPENAI_API_KEY=sk-...` at build time.
class OpenAiTranslationService {
  static const String _endpoint =
      'https://api.openai.com/v1/chat/completions';

  static String _apiKey = '';
  static bool _configured = false;

  /// Call once at app startup. Subsequent calls are ignored.
  static void configure({required String apiKey}) {
    if (_configured) return;
    assert(apiKey.isNotEmpty, 'OpenAI API key must not be empty.');
    _apiKey = apiKey;
    _configured = true;
  }

  /// Translates [text] from Arabic to English.
  /// Returns the original [text] if translation fails or [text] is empty.
  static Future<String> translateToEnglish(String text) async {
    if (text.isEmpty || _apiKey.isEmpty) return text;
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a professional Arabic-to-English translator. '
                  'Translate the following Arabic text to natural English. '
                  'Return only the translated text, no explanations.',
            },
            {'role': 'user', 'content': text},
          ],
          'max_tokens': 1024,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            data['choices']?[0]?['message']?['content'] as String? ?? text;
        return content.trim();
      } else {
        debugPrint(
          'OpenAI translation error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e, st) {
      debugPrint('OpenAI translateToEnglish exception: $e\n$st');
    }
    return text;
  }

  /// Translates a map of string fields from Arabic to English.
  /// Keys with empty values are skipped.
  static Future<Map<String, String>> translateFields(
    Map<String, String> fields,
  ) async {
    if (_apiKey.isEmpty) return fields;
    final entries = fields.entries.where((e) => e.value.isNotEmpty).toList();
    if (entries.isEmpty) return fields;

    // Build a single prompt for all fields to minimise API calls
    final prompt = entries.map((e) => '${e.key}: ${e.value}').join('\n\n');

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a professional Arabic-to-English translator. '
                  'The input contains labelled fields in the format "fieldName: arabicText". '
                  'Translate only the values (after the colon) to English. '
                  'Return the result in the exact same format with the original field names unchanged.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 2048,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            data['choices']?[0]?['message']?['content'] as String? ?? '';

        final result = Map<String, String>.from(fields);
        for (final line in content.split('\n')) {
          final idx = line.indexOf(':');
          if (idx < 0) continue;
          final key = line.substring(0, idx).trim();
          final value = line.substring(idx + 1).trim();
          if (result.containsKey(key)) {
            result[key] = value;
          }
        }
        return result;
      } else {
        debugPrint(
          'OpenAI translateFields error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e, st) {
      debugPrint('OpenAI translateFields exception: $e\n$st');
    }
    return fields;
  }
}
