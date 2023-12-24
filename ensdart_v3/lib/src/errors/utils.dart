part of 'errors.dart';

class FusesOutOfRangeError extends BaseError {
  @override
  final String name = 'FusesOutOfRangeError';

  FusesOutOfRangeError({
    required BigInt fuses,
    BigInt? minimum,
    BigInt? maximum,
    String? details,
  }) : super(
          shortMessage: 'Fuse value out of range',
          parameters: BaseErrorParameters(metaMessages: [
            '- Fuse value: $fuses',
            '- Allowed range: ${minimum ?? BigInt.zero}-${maximum ?? BigInt.from(2).pow(32)}',
          ], details: details),
        );
}

class FusesRestrictionNotAllowedError extends BaseError {
  @override
  final String name = 'FusesRestrictionNotAllowedError';

  FusesRestrictionNotAllowedError({
    dynamic fuses,
    String? details,
  }) : super(
          shortMessage: 'Restriction not allowed',
          parameters: BaseErrorParameters(
            metaMessages: ['- Fuse value: $fuses'],
            details: details,
          ),
        );
}

class FusesInvalidFuseObjectError extends BaseError {
  @override
  final String name = 'FusesInvalidFuseObjectError';

  FusesInvalidFuseObjectError(
      {required Map<String, dynamic> fuses, String? details})
      : super(
          shortMessage: 'Invalid fuse value',
          parameters: BaseErrorParameters(
            metaMessages: ['- Fuse value: $fuses'],
            details: details,
          ),
        );
}

class FusesValueRequiredError extends BaseError {
  @override
  final String name = 'FusesValueRequiredError';

  FusesValueRequiredError()
      : super(shortMessage: 'Must specify at least one fuse');
}

class FusesInvalidNamedFuseError extends BaseError {
  @override
  final String name = 'FusesInvalidNamedFuseError';

  FusesInvalidNamedFuseError({required String fuse})
      : super(shortMessage: '$fuse is not a valid named fuse');
}

class FusesFuseNotAllowedError extends BaseError {
  @override
  final String name = 'FusesFuseNotAllowedError';

  FusesFuseNotAllowedError({dynamic fuse})
      : super(shortMessage: '$fuse is not allowed for this operation');
}

class FusesInvalidUnnamedFuseError extends BaseError {
  @override
  final String name = 'FusesInvalidUnnamedFuseError';

  FusesInvalidUnnamedFuseError({dynamic fuse})
      : super(
          shortMessage: '$fuse is not a valid unnamed fuse',
          parameters: BaseErrorParameters(
            metaMessages: [
              '- If you are trying to set a named fuse, use the named property',
            ],
          ),
        );
}

class InvalidEncodedLabelError extends BaseError {
  @override
  final String name = 'InvalidEncodedLabelError';

  InvalidEncodedLabelError({required String label, String? details})
      : super(
          shortMessage: 'Invalid encoded label',
          parameters: BaseErrorParameters(
            metaMessages: ['- Supplied label: $label'],
            details: details,
          ),
        );
}

class InvalidLabelhashError extends BaseError {
  @override
  final String name = 'InvalidLabelhashError';

  InvalidLabelhashError({required String labelhash, String? details})
      : super(
          shortMessage: 'Invalid labelhash',
          parameters: BaseErrorParameters(
            metaMessages: ['- Supplied labelhash: $labelhash'],
            details: details,
          ),
        );
}

class NameWithEmptyLabelsError extends BaseError {
  @override
  final String name = 'NameWithEmptyLabelsError';

  NameWithEmptyLabelsError({required String name, String? details})
      : super(
          shortMessage: 'Name cannot have empty labels',
          parameters: BaseErrorParameters(
            metaMessages: ['- Supplied name: $name'],
            details: details,
          ),
        );
}

class RootNameIncludesOtherLabelsError extends BaseError {
  @override
  final String name = 'RootNameIncludesOtherLabelsError';

  RootNameIncludesOtherLabelsError({required String name})
      : super(
          shortMessage: 'Root name cannot have other labels',
          parameters: BaseErrorParameters(
            metaMessages: ['- Supplied name: $name'],
          ),
        );
}

class WrappedLabelTooLargeError extends BaseError {
  @override
  final String name = 'WrappedLabelTooLargeError';

  WrappedLabelTooLargeError({
    required String label,
    required num byteLength,
  }) : super(
          shortMessage: 'Supplied label was too long',
          parameters: BaseErrorParameters(
            metaMessages: [
              '- Supplied label: $label',
              '- Max byte length: 255',
              '- Actual byte length: $byteLength',
            ],
          ),
        );
}

class CampaignReferenceTooLargeError extends BaseError {
  @override
  final String name = 'CampaignReferenceTooLargeError';

  CampaignReferenceTooLargeError({required num campaign})
      : super(
          shortMessage: 'Campaign reference $campaign is too large',
          parameters: BaseErrorParameters(
            metaMessages: ['- Max campaign reference: ${0xffffffff}'],
          ),
        );
}

class InvalidContentHashError extends BaseError {
  @override
  final String name = 'InvalidContentHashError';

  InvalidContentHashError() : super(shortMessage: 'Invalid content hash');
}

class UnknownContentTypeError extends BaseError {
  @override
  final String name = 'UnknownContentTypeError';

  UnknownContentTypeError({required String contentType})
      : super(
          shortMessage: 'Unknown content type: $contentType',
        );
}
