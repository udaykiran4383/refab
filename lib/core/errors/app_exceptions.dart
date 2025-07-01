abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code}) : super(message, code: code);
}

class AuthException extends AppException {
  AuthException(String message, {String? code}) : super(message, code: code);
}

class ValidationException extends AppException {
  ValidationException(String message, {String? code}) : super(message, code: code);
}

class StorageException extends AppException {
  StorageException(String message, {String? code}) : super(message, code: code);
}

class PermissionException extends AppException {
  PermissionException(String message, {String? code}) : super(message, code: code);
}

class ServerException extends AppException {
  ServerException(String message, {String? code}) : super(message, code: code);
}

class CacheException extends AppException {
  CacheException(String message, {String? code}) : super(message, code: code);
}
