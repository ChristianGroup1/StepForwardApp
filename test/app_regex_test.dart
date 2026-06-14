import 'package:flutter_test/flutter_test.dart';
import 'package:stepforward/core/helper_functions/app_regex.dart';

void main() {
  group('AppRegex.isEmailValid', () {
    test('accepts common valid email formats', () {
      expect(AppRegex.isEmailValid('user@example.com'), isTrue);
      expect(AppRegex.isEmailValid('user.name+tag@example.co.uk'), isTrue);
      expect(AppRegex.isEmailValid('user123@example2.com'), isTrue);
    });

    test('rejects invalid email formats', () {
      expect(AppRegex.isEmailValid('userexample.com'), isFalse);
      expect(AppRegex.isEmailValid('user@'), isFalse);
      expect(AppRegex.isEmailValid('@example.com'), isFalse);
    });
  });

  group('AppRegex.isPasswordValid', () {
    test('accepts passwords that satisfy all displayed constraints', () {
      expect(AppRegex.isPasswordValid('Abcdef1@'), isTrue);
      expect(AppRegex.isPasswordValid('Abcdef1#'), isTrue);
      expect(AppRegex.isPasswordValid('Abcdef1^'), isTrue);
    });

    test('rejects passwords missing one required constraint', () {
      expect(AppRegex.isPasswordValid('abcdef1@'), isFalse);
      expect(AppRegex.isPasswordValid('ABCDEF1@'), isFalse);
      expect(AppRegex.isPasswordValid('Abcdefgh@'), isFalse);
      expect(AppRegex.isPasswordValid('Abcdef12'), isFalse);
      expect(AppRegex.isPasswordValid('Abc1@'), isFalse);
    });
  });
}
