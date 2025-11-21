import '../errors/failures.dart';

class ApiResponse<T> {
  final T? data;
  final Failure? failure;
  final bool isSuccess;

  const ApiResponse._({
    this.data,
    this.failure,
    required this.isSuccess,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse._(
      data: data,
      isSuccess: true,
    );
  }

  factory ApiResponse.failure(Failure failure) {
    return ApiResponse._(
      failure: failure,
      isSuccess: false,
    );
  }

  bool get isFailure => !isSuccess;

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    if (isSuccess && data != null) {
      return onSuccess(data as T);
    } else {
      return onFailure(failure!);
    }
  }

  ApiResponse<R> map<R>(R Function(T data) transform) {
    if (isSuccess && data != null) {
      return ApiResponse.success(transform(data as T));
    }
    return ApiResponse.failure(failure!);
  }
}
