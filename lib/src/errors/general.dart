import 'base.dart';

import '../types.dart';

class AdditionalParameterSpecifiedError extends BaseError {
  final String parameter;
  final List<String> allowedParameters;

  @override
  final String name = 'AdditionalParameterSpecifiedError';

  AdditionalParameterSpecifiedError({
    required this.parameter,
    required this.allowedParameters,
    String? details,
  }) : super(
          shortMessage: 'Additional parameter specified: $parameter',
          parameters: BaseErrorParameters(
            metaMessages: [
              '- Allowed parameters: ${allowedParameters.join(', ')}'
            ],
            details: details,
          ),
        );
}

class RequiredParameterNotSpecifiedError extends BaseError {
  final String parameter;

  @override
  final String name = 'RequiredParameterNotSpecifiedError';

  RequiredParameterNotSpecifiedError({required this.parameter, String? details})
      : super(
            shortMessage: 'Required parameter not specified: $parameter',
            parameters: BaseErrorParameters(details: details));
}

class UnsupportedNameTypeError extends BaseError {
  final NameType nameType;
  final List<NameType> supportedTypes;

  @override
  final String name = 'UnsupportedNameTypeError';

  UnsupportedNameTypeError({
    required this.nameType,
    required this.supportedTypes,
    String? details,
  }) : super(
          shortMessage: 'Unsupported name type: $nameType',
          parameters: BaseErrorParameters(
            metaMessages: [
              '- Supported name types: ${supportedTypes.join(', ')}'
            ],
            details: details,
          ),
        );
}

class InvalidContractTypeError extends BaseError {
  final String contractType;
  final List<String> supportedTypes;

  @override
  final String name = 'InvalidContractTypeError';

  InvalidContractTypeError({
    required this.contractType,
    required this.supportedTypes,
    String? details,
  }) : super(
          shortMessage: 'Invalid contract type: $contractType',
          parameters: BaseErrorParameters(
            metaMessages: [
              '- Supported contract types: ${supportedTypes.join(', ')}'
            ],
            details: details,
          ),
        );
}
