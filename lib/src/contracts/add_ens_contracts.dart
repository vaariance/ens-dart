part of 'contracts.dart';

/// Adds ENS contract addresses to the Viem chain
///
/// - chain - The Viem [Chain] object to add the ENS contracts to
/// todo
/// Example
/// ```dart
/// import '...';
/// import '...';
///
/// import 'contracts/constants.dart';
///
/// final clientWithEns = createPublicClient(
///   chain: addEnsContracts(mainnet),
///   transport: http.Client(),
/// );
/// ```
ChainWithEns<TChain> addEnsContracts<TChain extends Chain>(TChain? chain) {
  if (chain == null) {
    throw NoChainError();
  }

  if (!SupportedChains.values.any((e) => e.name == chain.network)) {
    throw UnsupportedNetworkError(
      network: chain.network,
      supportedNetworks: SupportedChains.values.map((e) => e.name).toList(),
    );
  }

  return ChainWithEns<TChain>(
    chain: chain,
    contracts: chain.contracts!.copyWith(
      Addresses.withNetwork(chain.network).toMap(),
    ),
  );
}
