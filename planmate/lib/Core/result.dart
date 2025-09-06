class Failure {
  final String message;
  final String? code;
  final StackTrace? stackTrace;
  const Failure(this.message, {this.code, this.stackTrace});
  @override
  String toString() => 'Failure(code: $code, message: $message)';
}

abstract class Result<T> {
  const Result();
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  });
  bool get isSuccess => this is Success<T>;
  T? get dataOrNull =>
      this is Success<T> ? (this as Success<T>).data : null;
  Failure? get failureOrNull =>
      this is Error<T> ? (this as Error<T>).failure : null;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) => success(data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) => error(failure);
}
