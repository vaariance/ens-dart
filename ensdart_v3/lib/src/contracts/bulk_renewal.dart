part of 'contracts.dart';

class BulkRenewal implements ContractInterfaceBase {
  @override
  String get name => "BulkRenewal";

  @override
  EthereumAddress? get address => null;

  @override
  ContractAbi get abi => ContractAbi.fromJson(_bulkRenewalAbi.toString(), name);

  @override
  String? get bytecode => null;

  @override
  String? get deployedBytecode => null;
}

final _bulkRenewalAbi = [
  {
    "inputs": [
      {
        "name": 'names',
        "type": 'string[]',
      },
      {
        "name": 'duration',
        "type": 'uint256',
      },
    ],
    "name": 'rentPrice',
    "outputs": [
      {
        "name": 'total',
        "type": 'uint256',
      },
    ],
    "stateMutability": 'view',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'names',
        "type": 'string[]',
      },
      {
        "name": 'duration',
        "type": 'uint256',
      },
    ],
    "name": 'renewAll',
    "outputs": [],
    "stateMutability": 'payable',
    "type": 'function',
  },
];
