part of 'errors.dart';

class BaseError extends Error {
  late String? details;
  late List<String?> metaMessages;
  String shortMessage;

  String get name => "Error";
  dynamic message;
  BaseError? cause;

  BaseError({
    required this.shortMessage,
    BaseErrorParameters parameters = const BaseErrorParameters(),
  }) {
    final causeDetails = parameters.cause is BaseError
        ? parameters.cause?.details
        : parameters.cause?.message ?? parameters.details;

    message = [
      shortMessage,
      '',
      if (parameters.metaMessages.isNotEmpty) ...parameters.metaMessages,
      if (causeDetails != null && causeDetails.isNotEmpty)
        'Details: $causeDetails',
      'Version: $version',
    ].join('\n');

    cause = parameters.cause;
    details = causeDetails;
    metaMessages = parameters.metaMessages;
    shortMessage = shortMessage;
  }

  String get version => Version().getVersion();
}

class BaseErrorParameters {
  final List<String?> metaMessages;
  final BaseError? cause;
  final String? details;

  const BaseErrorParameters({
    this.metaMessages = const [],
    this.cause,
    this.details,
  });
}
