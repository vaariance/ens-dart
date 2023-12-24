part of 'errors.dart';

class CoinFormatterNotFoundError extends BaseError {
  final String? coinType;

  @override
  final String name = 'CoinFormatterNotFoundError';

  CoinFormatterNotFoundError({this.coinType})
      : super(
            shortMessage:
                'Coin formatter not found for ${coinType ?? "unknown"}');
}

class FunctionNotBatchableError extends BaseError {
  final int functionIndex;

  @override
  final String name = 'FunctionNotBatchableError';

  FunctionNotBatchableError({required this.functionIndex})
      : super(
            shortMessage: 'Function at index $functionIndex is not batchable');
}

class NoRecordsSpecifiedError extends BaseError {
  @override
  final String name = 'NoRecordsSpecifiedError';

  NoRecordsSpecifiedError() : super(shortMessage: 'No records specified');
}
