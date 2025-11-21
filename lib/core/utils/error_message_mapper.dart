import '../errors/failures.dart';

class ErrorMessageMapper {
  ErrorMessageMapper._();

  static String getReadableMessage(Failure failure) {
    if (failure.code != null) {
      switch (failure.code) {
        case '401':
        case 'UNAUTHORIZED':
          return 'Invalid email or password. Please check your credentials and try again.';
        case '403':
          return 'Access denied. You don\'t have the necessary permissions for this action.';
        case '404':
        case 'NOT_FOUND':
          return 'We couldn\'t find what you\'re looking for. It may have been removed or doesn\'t exist.';
        case '409':
        case 'CONFLICT':
          return 'This item already exists.';
        case 'NETWORK_ERROR':
          return 'Unable to connect to the internet. Please check your network connection and try again.';
        case 'CACHE_ERROR':
          return 'Unable to load saved data. Please try refreshing.';
      }
    }

    if (failure is NetworkFailure) {
      if (failure.message.contains('timeout') || 
          failure.message.contains('TimeoutException')) {
        return 'The connection took too long. Please check your internet and try again.';
      }
      if (failure.message.contains('SocketException') ||
          failure.message.contains('Failed host lookup')) {
        return 'Unable to reach our servers. Please check your internet connection.';
      }
      return 'Network error occurred. Please check your internet connection and try again.';
    }

    if (failure is AuthenticationFailure) {
      if (failure.message.contains('email')) {
        return 'Please enter a valid email address.';
      }
      if (failure.message.contains('password')) {
        return 'Your password must be at least 6 characters long.';
      }
      if (failure.message.contains('Invalid') || 
          failure.message.contains('incorrect')) {
        return 'The email or password you entered is incorrect. Please try again.';
      }
      return 'We couldn\'t log you in. Please check your credentials and try again.';
    }

    if (failure is UnauthorizedFailure) {
      return 'Your session has expired. Please log in again to continue.';
    }

    if (failure is ValidationFailure) {
      return failure.message; 
    }

    if (failure is NotFoundFailure) {
      return 'The item you\'re looking for couldn\'t be found.';
    }

    if (failure is ConflictFailure) {
      if (failure.message.contains('email')) {
        return 'This email address is already registered. Please try logging in or use a different email.';
      }
      if (failure.message.contains('NORAD')) {
        return 'This satellite is already in your tracking list.';
      }
      return 'This item already exists. Please check your list.';
    }

    if (failure is ServerFailure) {
      if (failure.message.contains('500')) {
        return 'Our servers are having trouble right now. Please try again in a few moments.';
      }
      return 'Something went wrong on our end. Please try again later.';
    }

    return 'An unexpected error occurred. Please try again or contact support if the problem persists.';
  }

  static String getErrorTitle(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Connection Error';
    }
    if (failure is AuthenticationFailure) {
      return 'Login Failed';
    }
    if (failure is UnauthorizedFailure) {
      return 'Access Denied';
    }
    if (failure is ValidationFailure) {
      return 'Invalid Input';
    }
    if (failure is NotFoundFailure) {
      return 'Not Found';
    }
    if (failure is ConflictFailure) {
      return 'Already Exists';
    }
    if (failure is ServerFailure) {
      return 'Server Error';
    }
    return 'Error';
  }
}
