part of 'contracts.dart';

abstract class ChainClient<TChain extends ChainWithEns> {
  TChain get clientChain;
}

EthereumAddress _getChainContractAddress({
  BlockNum? blockNumber,
  required Chain chain,
  required SupportedContracts name,
}) {
  final contract = chain.contracts?.getChainContractFromName(name);

  if (contract == null) {
    throw Exception('Chain does not support contract');
  }

  if (blockNumber != null &&
      contract.blockCreated != null &&
      contract.blockCreated!.blockNum > blockNumber.blockNum) {
    throw Exception(
        'Chain does not support contract at block ${blockNumber.blockNum}');
  }

  return contract.address;
}

EthereumAddress getChainContractAddress<TChain extends ChainWithEns,
        TClient extends ChainClient<TChain>>({
  BlockNum? blockNumber,
  required TClient client,
  required SupportedContracts name,
}) =>
    _getChainContractAddress(
        blockNumber: blockNumber, chain: client.clientChain.chain, name: name);
