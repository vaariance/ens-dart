part of 'contracts.dart';

class DNSSECImpl implements ContractInterfaceBase {
  @override
  String get name => "DNSSECImpl";

  @override
  EthereumAddress? get address => null;

  @override
  ContractAbi get abi => ContractAbi.fromJson(_dnssecImplAbi.toString(), name);

  @override
  String? get bytecode => null;

  @override
  String? get deployedBytecode => null;
}

final _dnssecImplAbi = [
  {
    "inputs": [
      {
        "name": 'dnstype',
        "type": 'uint16',
      },
      {
        "name": 'name',
        "type": 'bytes',
      },
    ],
    "name": 'rrdata',
    "outputs": [
      {
        "name": '',
        "type": 'uint32',
      },
      {
        "name": '',
        "type": 'uint32',
      },
      {
        "name": '',
        "type": 'bytes20',
      },
    ],
    "stateMutability": 'view',
    "type": 'function',
  },
  {
    "inputs": [],
    "name": 'anchors',
    "outputs": [
      {
        "name": '',
        "type": 'bytes',
      },
    ],
    "stateMutability": 'view',
    "type": 'function',
  },
];
