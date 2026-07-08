sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final String message;
  final FailureCode code;
  const Failure(this.message, {this.code = FailureCode.unknown});
}

enum FailureCode {
  validationError,
  notFound,
  databaseError,
  unknown,
}