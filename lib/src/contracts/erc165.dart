part of 'contracts.dart';

class ERC165 implements ContractInterfaceBase {
  @override
  String get name => "ERC165";

  @override
  EthereumAddress? get address => null;

  @override
  ContractAbi get abi => ContractAbi.fromJson(_erc165Abi.toString(), name);

  @override
  String? get bytecode => null;

  @override
  String? get deployedBytecode => null;
}

final _erc165Abi = [
  {
    "inputs": [
      {
        "name": 'interfaceID',
        "type": 'bytes4',
      },
    ],
    "name": 'supportsInterface',
    "outputs": [
      {
        "name": '',
        "type": 'bool',
      },
    ],
    "stateMutability": 'pure',
    "type": 'function',
  },
];
