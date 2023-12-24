part of 'contracts.dart';

class Addresses {
  final ChainContract ensRegistry;
  final ChainContract ensBaseRegistrarImplementation;
  final ChainContract ensDnsRegistrar;
  final ChainContract ensEthRegistrarController;
  final ChainContract ensNameWrapper;
  final ChainContract ensPublicResolver;
  final ChainContract ensReverseRegistrar;
  final ChainContract ensBulkRenewal;
  final ChainContract ensDnssecImpl;
  final ChainContract ensUniversalResolver;

  factory Addresses.withGoerli() {
    return Addresses._(
        ensRegistry: ChainContract(
            address: EthereumAddress.fromHex(
                "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e")),
        ensBaseRegistrarImplementation: ChainContract(
            address: EthereumAddress.fromHex(
                "0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85")),
        ensDnsRegistrar: ChainContract(
            address: EthereumAddress.fromHex(
                "0x8edc487D26F6c8Fa76e032066A3D4F87E273515d")),
        ensEthRegistrarController: ChainContract(
            address: EthereumAddress.fromHex(
                "0xCc5e7dB10E65EED1BBD105359e7268aa660f6734")),
        ensNameWrapper: ChainContract(
            address: EthereumAddress.fromHex(
                "0x114D4603199df73e7D157787f8778E21fCd13066")),
        ensPublicResolver: ChainContract(
            address: EthereumAddress.fromHex(
                "0xd7a4F6473f32aC2Af804B3686AE8F1932bC35750")),
        ensReverseRegistrar: ChainContract(
            address: EthereumAddress.fromHex(
                "0x6d9F26FfBcF1c6f0bAe9F2C1f7fBe8eE6B1d8d4d")),
        ensBulkRenewal: ChainContract(
            address: EthereumAddress.fromHex(
                "0x6d9F26FfBcF1c6f0bAe9F2C1f7fBe8eE6B1d8d4d")),
        ensDnssecImpl: ChainContract(
            address: EthereumAddress.fromHex(
                "0xF427c4AdED8B6dfde604865c1a7E953B160C26f0")),
        ensUniversalResolver: ChainContract(
            address: EthereumAddress.fromHex(
                "0xaac727b9451268d7779F699dbaF6c2eAE571C369")));
  }

  factory Addresses.withHomestead() {
    return Addresses._(
        ensRegistry: ChainContract(
            address: EthereumAddress.fromHex(
                "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e")),
        ensBaseRegistrarImplementation: ChainContract(
            address: EthereumAddress.fromHex(
                "0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85")),
        ensDnsRegistrar: ChainContract(
            address: EthereumAddress.fromHex(
                "0x58774Bb8acD458A640aF0B88238369A167546ef2")),
        ensEthRegistrarController: ChainContract(
            address: EthereumAddress.fromHex(
                "0x253553366Da8546fC250F225fe3d25d0C782303b")),
        ensNameWrapper: ChainContract(
            address: EthereumAddress.fromHex(
                "0xD4416b13d2b3a9aBae7AcD5D6C2BbDBE25686401")),
        ensPublicResolver: ChainContract(
            address: EthereumAddress.fromHex(
                "0x231b0Ee14048e9dCcD1d247744d114a4EB5E8E63")),
        ensReverseRegistrar: ChainContract(
            address: EthereumAddress.fromHex(
                "0xa58E81fe9b61B5c3fE2AFD33CF304c454AbFc7Cb")),
        ensBulkRenewal: ChainContract(
            address: EthereumAddress.fromHex(
                "0xa12159e5131b1eEf6B4857EEE3e1954744b5033A")),
        ensDnssecImpl: ChainContract(
            address: EthereumAddress.fromHex(
                "0x21745FF62108968fBf5aB1E07961CC0FCBeB2364")),
        ensUniversalResolver: ChainContract(
            address: EthereumAddress.fromHex(
                "0x20814C8e689187DfF7C93A9239ea22385d13b9F1")));
  }

  factory Addresses.withNetwork(String network) {
    switch (network) {
      case 'homestead':
        return Addresses.withHomestead();
      case 'goerli':
        return Addresses.withGoerli();
      case 'sepolia':
        return Addresses.withSepolia();
      default:
        throw UnsupportedNetworkError(
          network: network,
          supportedNetworks: SupportedChains.values.map((e) => e.name).toList(),
        );
    }
  }

  factory Addresses.withSepolia() {
    return Addresses._(
        ensRegistry: ChainContract(
            address: EthereumAddress.fromHex(
                "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e")),
        ensBaseRegistrarImplementation: ChainContract(
            address: EthereumAddress.fromHex(
                "0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85")),
        ensDnsRegistrar: ChainContract(
            address: EthereumAddress.fromHex(
                "0x537625B0D7901FD20C57850d61580Bf1624Ef146")),
        ensEthRegistrarController: ChainContract(
            address: EthereumAddress.fromHex(
                "0xFED6a969AaA60E4961FCD3EBF1A2e8913ac65B72")),
        ensNameWrapper: ChainContract(
            address: EthereumAddress.fromHex(
                "0x0635513f179D50A207757E05759CbD106d7dFcE8")),
        ensPublicResolver: ChainContract(
            address: EthereumAddress.fromHex(
                "0x8FADE66B79cC9f707aB26799354482EB93a5B7dD")),
        ensReverseRegistrar: ChainContract(
            address: EthereumAddress.fromHex(
                "0xA0a1AbcDAe1a2a4A2EF8e9113Ff0e02DD81DC0C6")),
        ensBulkRenewal: ChainContract(
            address: EthereumAddress.fromHex(
                "0x4EF77b90762Eddb33C8Eba5B5a19558DaE53D7a1")),
        ensDnssecImpl: ChainContract(
            address: EthereumAddress.fromHex(
                "0x7b3ada1c8f012bae747cf99d6cbbf70d040b84cf")),
        ensUniversalResolver: ChainContract(
            address: EthereumAddress.fromHex(
                "0x64da0719987c29e0CEC0113D605996c6a4D4aB0c")));
  }

  const Addresses._(
      {required this.ensRegistry,
      required this.ensBaseRegistrarImplementation,
      required this.ensDnsRegistrar,
      required this.ensEthRegistrarController,
      required this.ensNameWrapper,
      required this.ensPublicResolver,
      required this.ensReverseRegistrar,
      required this.ensBulkRenewal,
      required this.ensDnssecImpl,
      required this.ensUniversalResolver});

  Map<String, ChainContract> toMap() {
    return <String, ChainContract>{
      'ensRegistry': ensRegistry,
      'ensBaseRegistrarImplementation': ensBaseRegistrarImplementation,
      'ensDnsRegistrar': ensDnsRegistrar,
      'ensEthRegistrarController': ensEthRegistrarController,
      'ensNameWrapper': ensNameWrapper,
      'ensPublicResolver': ensPublicResolver,
      'ensReverseRegistrar': ensReverseRegistrar,
      'ensBulkRenewal': ensBulkRenewal,
      'ensDnssecImpl': ensDnssecImpl,
      'ensUniversalResolver': ensUniversalResolver,
    };
  }
}

class BaseChainContracts {
  ChainContract? ensRegistry;
  ChainContract? ensUniversalResolver;
  ChainContract? multicall3;
  BaseChainContracts(
      {this.ensRegistry, this.ensUniversalResolver, this.multicall3});
}

class Chain {
  ChainBlockExplorer? blockExplorers;
  ExtendedChainContract? contracts;
  int id;
  String name;
  @Deprecated('will be removed in the future - use [id] instead.')
  String network;
  ChainNativeCurrency nativeCurrency;
  Map<String, ChainRpcUrls> rpcUrls;
  num? sourceId;
  bool? testnet;

  Chain(
      {this.blockExplorers,
      this.contracts,
      required this.id,
      required this.name,
      required this.network,
      required this.nativeCurrency,
      required this.rpcUrls,
      this.testnet,
      this.sourceId});

  Chain copyWith({
    ExtendedChainContract? contracts,
    int? id,
    String? name,
    String? network,
    ChainNativeCurrency? nativeCurrency,
    Map<String, ChainRpcUrls>? rpcUrls,
    num? sourceId,
    bool? testnet,
  }) {
    return Chain(
      contracts: contracts ?? this.contracts,
      id: id ?? this.id,
      name: name ?? this.name,
      network: network ?? this.network,
      rpcUrls: rpcUrls ?? this.rpcUrls,
      sourceId: sourceId ?? this.sourceId,
      testnet: testnet ?? this.testnet,
      nativeCurrency: nativeCurrency ?? this.nativeCurrency,
    );
  }
}

class ChainBlockExplorer {
  String name;
  String url;
  ChainBlockExplorer({required this.name, required this.url});
}

class ChainContract {
  EthereumAddress address;
  BlockNum? blockCreated;

  ChainContract({required this.address, this.blockCreated});
}

class ChainNativeCurrency {
  String name;
  String symbol;
  int decimals;
  ChainNativeCurrency(
      {required this.name, required this.symbol, required this.decimals});
}

class ChainRpcUrls {
  String http;
  String? webSocket;
  ChainRpcUrls({required this.http, this.webSocket});
}

class ChainWithEns<TChain extends Chain> {
  TChain chain;
  ExtendedChainContract contracts;
  ChainWithEns({required this.chain, required this.contracts});
}

class ClientWithEns<TTransport extends http.Client, TChain extends ChainWithEns,
    TAccount extends CredentialsWithKnownAddress?> {
  Web3Client client;
  TAccount? account;
  TChain chain;

  ClientWithEns({
    required TTransport tTransport,
    required this.chain,
    this.account,
  })  : assert(chain.chain.rpcUrls['default'] != null),
        client = Web3Client(chain.chain.rpcUrls['default']!.http, tTransport);
}

class EnsChainContracts {
  ChainContract ensBaseRegistrarImplementation;
  ChainContract ensBulkRenewal;
  ChainContract ensDnsRegistrar;
  ChainContract ensDnssecImpl;
  ChainContract ensEthRegistrarController;
  ChainContract ensNameWrapper;
  ChainContract ensPublicResolver;
  ChainContract? ensRegistry;
  ChainContract ensReverseRegistrar;
  ChainContract? ensUniversalResolver;

  EnsChainContracts(
      {required this.ensBaseRegistrarImplementation,
      required this.ensBulkRenewal,
      required this.ensDnsRegistrar,
      required this.ensDnssecImpl,
      required this.ensEthRegistrarController,
      required this.ensNameWrapper,
      required this.ensPublicResolver,
      this.ensRegistry,
      required this.ensReverseRegistrar,
      this.ensUniversalResolver});
}

class ExtendedChainContract implements BaseChainContracts, EnsChainContracts {
  @override
  ChainContract ensBaseRegistrarImplementation;

  @override
  ChainContract ensBulkRenewal;

  @override
  ChainContract ensDnsRegistrar;

  @override
  ChainContract ensDnssecImpl;

  @override
  ChainContract ensEthRegistrarController;

  @override
  ChainContract ensNameWrapper;

  @override
  ChainContract ensPublicResolver;

  @override
  ChainContract? ensRegistry;

  @override
  ChainContract ensReverseRegistrar;

  @override
  ChainContract? ensUniversalResolver;

  @override
  ChainContract? multicall3;

  ExtendedChainContract({
    required this.ensBaseRegistrarImplementation,
    required this.ensBulkRenewal,
    required this.ensDnsRegistrar,
    required this.ensDnssecImpl,
    required this.ensEthRegistrarController,
    required this.ensNameWrapper,
    required this.ensPublicResolver,
    this.ensRegistry,
    required this.ensReverseRegistrar,
    this.ensUniversalResolver,
    this.multicall3,
  });

  ExtendedChainContract copyWith(Map<String, ChainContract?> spread) {
    return ExtendedChainContract(
      ensBaseRegistrarImplementation:
          spread['ensBaseRegistrarImplementation'] ??
              ensBaseRegistrarImplementation,
      ensBulkRenewal: spread['ensBulkRenewal'] ?? ensBulkRenewal,
      ensDnsRegistrar: spread['ensDnsRegistrar'] ?? ensDnsRegistrar,
      ensDnssecImpl: spread['ensDnssecImpl'] ?? ensDnssecImpl,
      ensEthRegistrarController:
          spread['ensEthRegistrarController'] ?? ensEthRegistrarController,
      ensNameWrapper: spread['ensNameWrapper'] ?? ensNameWrapper,
      ensPublicResolver: spread['ensPublicResolver'] ?? ensPublicResolver,
      ensRegistry: spread['ensRegistry'] ?? ensRegistry,
      ensReverseRegistrar: spread['ensReverseRegistrar'] ?? ensReverseRegistrar,
      ensUniversalResolver:
          spread['ensUniversalResolver'] ?? ensUniversalResolver,
      multicall3: spread['multicall3'] ?? multicall3,
    );
  }
}

enum SupportedChains { homestead, goerli, sepolia }

enum SupportedContracts {
  ensBaseRegistrarImplementation,
  ensDnsRegistrar,
  ensEthRegistrarController,
  ensNameWrapper,
  ensPublicResolver,
  ensReverseRegistrar,
  ensBulkRenewal,
  ensDnssecImpl,
  ensUniversalResolver,
  ensRegistry
}

extension ChainContractExtension on ExtendedChainContract {
  ChainContract getChainContractFromName(SupportedContracts name) {
    switch (name) {
      case SupportedContracts.ensBaseRegistrarImplementation:
        return ensBaseRegistrarImplementation;
      case SupportedContracts.ensBulkRenewal:
        return ensBulkRenewal;
      case SupportedContracts.ensDnsRegistrar:
        return ensDnsRegistrar;
      case SupportedContracts.ensDnssecImpl:
        return ensDnssecImpl;
      case SupportedContracts.ensEthRegistrarController:
        return ensEthRegistrarController;
      case SupportedContracts.ensNameWrapper:
        return ensNameWrapper;
      case SupportedContracts.ensPublicResolver:
        return ensPublicResolver;
      case SupportedContracts.ensReverseRegistrar:
        return ensReverseRegistrar;
      case SupportedContracts.ensUniversalResolver:
        return ensUniversalResolver!;
      case SupportedContracts.ensRegistry:
        return ensRegistry!;
      default:
        throw Exception('Unsupported contract');
    }
  }
}
