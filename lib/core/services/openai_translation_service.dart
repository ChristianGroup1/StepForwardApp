import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stepforward/core/utils/app_constants.dart';

/// Service that uses OpenAI ChatGPT to translate Arabic content to English.
///
/// Translations are cached in-memory for the duration of the app session to
/// avoid repeated API calls for the same text.
class OpenAITranslationService {
  static const String _apiUrl =
      'https://api.openai.com/v1/chat/completions';

  /// In-memory cache: key → translated text
  static final Map<String, String> _cache = {};

  /// Translates [text] from Arabic to English using the OpenAI API.
  /// Returns the original [text] if:
  ///   - [text] is empty
  ///   - the API key is not configured
  ///   - the request fails
  static Future<String> translateToEnglish(String text) async {
    if (text.trim().isEmpty) return text;

    final cacheKey = 'en:$text';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    if (kOpenAiApiKey.isEmpty) {
      return text;
    }

    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $kOpenAiApiKey',
            },
            body: jsonEncode({
              'model': 'gpt-3.5-turbo',
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are a professional translator. Translate the following Arabic text to English. '
                      'Return only the translated text without any explanation or extra content.',
                },
                {'role': 'user', 'content': text},
              ],
              'max_tokens': 1500,
              'temperature': 0.3,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        final translation =
            (json['choices'][0]['message']['content'] as String).trim();
        _cache[cacheKey] = translation;
        return translation;
      }
    } catch (_) {
      // Fall through and return original text on any error
    }

    return text;
  }

  /// Translates a list of Arabic strings to English in a single API call.
  /// Returns the original list if the API key is not configured or the
  /// request fails.
  static Future<List<String>> translateListToEnglish(
    List<String> texts,
  ) async {
    final nonEmpty = texts.where((t) => t.trim().isNotEmpty).toList();
    if (nonEmpty.isEmpty || kOpenAiApiKey.isEmpty) return texts;

    // Check if all are cached
    final cacheKeys = texts.map((t) => 'en:$t').toList();
    if (cacheKeys.every((k) => _cache.containsKey(k))) {
      return texts
          .map((t) => t.trim().isEmpty ? t : _cache['en:$t']!)
          .toList();
    }

    final numbered = texts
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');

    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $kOpenAiApiKey',
            },
            body: jsonEncode({
              'model': 'gpt-3.5-turbo',
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are a professional translator. Translate the following numbered Arabic texts to English. '
                      'Keep the same numbering format. Return only the numbered translations.',
                },
                {'role': 'user', 'content': numbered},
              ],
              'max_tokens': 2000,
              'temperature': 0.3,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        final content =
            (json['choices'][0]['message']['content'] as String).trim();
        final lines = content.split('\n');
        final result = List<String>.from(texts);
        for (final line in lines) {
          final match = RegExp(r'^(\d+)\.\s*(.+)$').firstMatch(line.trim());
          if (match != null) {
            final idx = int.tryParse(match.group(1)!);
            final translation = match.group(2)!;
            if (idx != null && idx >= 1 && idx <= texts.length) {
              result[idx - 1] = translation;
              _cache['en:${texts[idx - 1]}'] = translation;
            }
          }
        }
        return result;
      }
    } catch (_) {
      // Fall through and return original texts on any error
    }

    return texts;
  }

  /// Clears the translation cache.
  static void clearCache() => _cache.clear();
}
