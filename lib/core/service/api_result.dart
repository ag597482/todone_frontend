/// Result of an API call: either success with [data] or failure with [message].
sealed class ApiResult<T> {
  const ApiResult();
  bool get isSuccess => this is ApiSuccess<T>;
  bool get isFailure => this is ApiFailure<T>;
  T? get dataOrNull => switch (this) {
        ApiSuccess(:final data) => data,
        ApiFailure() => null,
      };
  String? get messageOrNull => switch (this) {
        ApiSuccess() => null,
        ApiFailure(:final message) => message,
      };
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
}
