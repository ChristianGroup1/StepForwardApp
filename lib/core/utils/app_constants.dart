/// OpenAI API key used by [OpenAITranslationService] to translate content.
///
/// Supply the key at build time using a `--dart-define` flag, for example:
///
/// ```
/// flutter run --dart-define=OPENAI_API_KEY=sk-proj-XXXXXXXXXXXXXXXXXXXX
/// flutter build apk --dart-define=OPENAI_API_KEY=sk-proj-XXXXXXXXXXXXXXXXXXXX
/// ```
///
/// If the key is not provided, translation silently falls back to showing
/// the original Arabic text.
const String kOpenAiApiKey = String.fromEnvironment(
  'OPENAI_API_KEY',
  defaultValue: '',
);
