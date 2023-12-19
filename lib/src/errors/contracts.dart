import 'base.dart';

class UnsupportedNetworkError extends BaseError {
  final String network;
  final List<String> supportedNetworks;

  @override
  final String name = 'UnsupportedNetworkError';

  UnsupportedNetworkError({
    required this.network,
    required this.supportedNetworks,
    String? details,
  }) : super(
          shortMessage: 'Unsupported network: $network',
          parameters: BaseErrorParameters(
            metaMessages: [
              '- Supported networks: ${supportedNetworks.join(', ')}',
            ],
            details: details,
          ),
        );
}

class NoChainError extends BaseError {
  @override
  final String name = 'NoChainError';

  NoChainError({String? details})
      : super(
            shortMessage: 'No chain provided',
            parameters: BaseErrorParameters(details: details));
}
