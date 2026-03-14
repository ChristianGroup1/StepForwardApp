import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Translation service with in-memory cache and multiple free backends.
///
/// Primary:  Unofficial Google Translate endpoint (high limits, no API key).
/// Fallback: MyMemory free API (5,000 chars/day; 10,000 with e-mail).
///
/// The in-memory cache ensures each unique Arabic string is translated only
/// once per app session, drastically reducing API calls.
class OpenAiTranslationService {
  // ── Cache ─────────────────────────────────────────────────────────────────
  static final Map<String, String> _cache = {};

  // ── Backends ──────────────────────────────────────────────────────────────
  static const _googleEndpoint =
      'https://translate.googleapis.com/translate_a/single';
  static const _myMemoryEndpoint = 'https://api.mymemory.translated.net/get';
  static String _email = 'fadykhayrat@gmail.com';

  /// Optionally configure the MyMemory e-mail address for higher daily limits.
  static void configure({String email = '', String apiKey = ''}) {
    final addr = email.isNotEmpty ? email : apiKey;
    if (addr.isNotEmpty && addr.contains('@')) _email = addr;
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Translates [text] from Arabic to English.
  /// Returns the original [text] if translation fails or [text] is empty.
  static Future<String> translateToEnglish(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;
    if (_cache.containsKey(trimmed)) return _cache[trimmed]!;

    // Try primary backend first.
    String? result = await _googleTranslate(trimmed);
    if (result == null || result.isEmpty || result == trimmed) {
      result = await _myMemoryTranslate(trimmed);
    }

    final translated = (result != null && result.isNotEmpty) ? result : trimmed;
    _cache[trimmed] = translated;
    return translated;
  }

  /// Translates a map of string fields from Arabic to English.
  static Future<Map<String, String>> translateFields(
    Map<String, String> fields,
  ) async {
    final result = Map<String, String>.from(fields);
    await Future.wait(
      fields.entries
          .where((e) => e.value.isNotEmpty)
          .map((e) async {
            result[e.key] = await translateToEnglish(e.value);
          }),
    );
    return result;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static Future<String?> _googleTranslate(String text) async {
    try {
      final uri = Uri.parse(_googleEndpoint).replace(queryParameters: {
        'client': 'gtx',
        'sl': 'ar',
        'tl': 'en',
        'dt': 't',
        'q': text,
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final parts = data[0] as List<dynamic>;
        final translated = parts
            .map((p) => (p as List<dynamic>)[0]?.toString() ?? '')
            .join();
        return translated.trim();
      }
    } catch (e) {
      debugPrint('Google translate error: $e');
    }
    return null;
  }

  static Future<String?> _myMemoryTranslate(String text) async {
    try {
      final uri = Uri.parse(_myMemoryEndpoint).replace(queryParameters: {
        'q': text,
        'langpair': 'ar|en',
        if (_email.isNotEmpty) 'de': _email,
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final translated =
            data['responseData']?['translatedText'] as String? ?? text;
        // MyMemory returns error text in the translated field when quota exceeded.
        if (translated.contains('MYMEMORY WARNING')) return null;
        return translated.trim();
      }
    } catch (e) {
      debugPrint('MyMemory translate error: $e');
    }
    return null;
  }
}
