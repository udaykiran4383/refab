import 'package:flutter_test/flutter_test.dart';
import 'package:refab_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('should return null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), null);
        expect(Validators.validateEmail('user.name@domain.co.uk'), null);
      });

      test('should return error for invalid email', () {
        expect(Validators.validateEmail('invalid-email'), isNotNull);
        expect(Validators.validateEmail('test@'), isNotNull);
        expect(Validators.validateEmail('@example.com'), isNotNull);
      });

      test('should return error for empty email', () {
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail(null), isNotNull);
      });
    });

    group('validatePassword', () {
      test('should return null for valid password', () {
        expect(Validators.validatePassword('password123'), null);
        expect(Validators.validatePassword('123456'), null);
      });

      test('should return error for short password', () {
        expect(Validators.validatePassword('12345'), isNotNull);
        expect(Validators.validatePassword('abc'), isNotNull);
      });

      test('should return error for empty password', () {
        expect(Validators.validatePassword(''), isNotNull);
        expect(Validators.validatePassword(null), isNotNull);
      });
    });

    group('validatePhone', () {
      test('should return null for valid phone', () {
        expect(Validators.validatePhone('1234567890'), null);
        expect(Validators.validatePhone('+91-9876543210'), null);
        expect(Validators.validatePhone('(123) 456-7890'), null);
      });

      test('should return error for invalid phone', () {
        expect(Validators.validatePhone('123'), isNotNull);
        expect(Validators.validatePhone('abcdefghij'), isNotNull);
      });

      test('should return error for empty phone', () {
        expect(Validators.validatePhone(''), isNotNull);
        expect(Validators.validatePhone(null), isNotNull);
      });
    });

    group('validateWeight', () {
      test('should return null for valid weight', () {
        expect(Validators.validateWeight('5.5'), null);
        expect(Validators.validateWeight('100'), null);
        expect(Validators.validateWeight('0.1'), null);
      });

      test('should return error for invalid weight', () {
        expect(Validators.validateWeight('0'), isNotNull);
        expect(Validators.validateWeight('-5'), isNotNull);
        expect(Validators.validateWeight('1001'), isNotNull);
        expect(Validators.validateWeight('abc'), isNotNull);
      });

      test('should return error for empty weight', () {
        expect(Validators.validateWeight(''), isNotNull);
        expect(Validators.validateWeight(null), isNotNull);
      });
    });
  });
}
