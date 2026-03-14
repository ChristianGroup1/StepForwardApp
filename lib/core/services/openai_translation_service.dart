import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Free translation service using the MyMemory API.
///
/// No API key is required.  Free tier allows up to 5,000 characters per day
/// (per IP).  For higher limits register a free account at
/// https://mymemory.translated.net and pass your email to [configure].
///
/// The class keeps the same public interface as the previous OpenAI-based
/// implementation so that no other files need to change.
class OpenAiTranslationService {
  static const String _endpoint = 'https://api.mymemory.translated.net/get';

  /// Optional registered e-mail address for the MyMemory free tier.
  /// Passing an e-mail doubles the daily character limit to 10,000.
  static String _email = '';

  /// Optionally pass a registered MyMemory [email] to increase the daily
  /// character limit from 5,000 to 10,000.  Omit or pass an empty string
  /// to use the service without any account — it works out of the box.
  static void configure({String email = '', String apiKey = ''}) {
    // Accept either named parameter for backward compatibility.
    final addr = email.isNotEmpty ? email : apiKey;
    if (addr.isNotEmpty && addr.contains('@')) {
      _email = addr;
    }
  }

  /// Translates [text] from Arabic to English using the MyMemory free API.
  /// Returns the original [text] if translation fails or [text] is empty.
  static Future<String> translateToEnglish(String text) async {
    if (text.isEmpty) return text;
    try {
      final queryParams = {
        'q': text,
        'langpair': 'ar|en',
        if (_email.isNotEmpty) 'de': _email,
      };
      final uri = Uri.parse(_endpoint).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final translated =
            data['responseData']?['translatedText'] as String? ?? text;
        return translated.trim();
      } else {
        debugPrint(
          'MyMemory translation error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e, st) {
      debugPrint('MyMemory translateToEnglish exception: $e\n$st');
    }
    return text;
  }

  /// Translates a map of string fields from Arabic to English.
  /// Each field is translated in a separate request to keep individual texts
  /// within the API's per-request length limit.
  static Future<Map<String, String>> translateFields(
    Map<String, String> fields,
  ) async {
    final entries = fields.entries.where((e) => e.value.isNotEmpty).toList();
    if (entries.isEmpty) return fields;

    final result = Map<String, String>.from(fields);

    // Translate each field individually (MyMemory works best per-sentence).
    await Future.wait(
      entries.map((e) async {
        result[e.key] = await translateToEnglish(e.value);
      }),
    );

    return result;
  }
}
