part of 'contracts.dart';

class DNSRegistrar implements ContractInterfaceBase {
  @override
  String get name => "DNSRegistrar";

  @override
  EthereumAddress? get address => null;

  @override
  ContractAbi get abi =>
      ContractAbi.fromJson(_dnsRegistrarAbi.toString(), name);

  @override
  String? get bytecode => null;

  @override
  String? get deployedBytecode => null;
}

final _dnsRegistrarAbi = [
  {
    "inputs": [
      {
        "name": 'name',
        "type": 'bytes',
      },
      {
        "components": [
          {
            "name": 'rrset',
            "type": 'bytes',
          },
          {
            "name": 'sig',
            "type": 'bytes',
          },
        ],
        "name": 'input',
        "type": 'tuple[]',
      },
      {
        "name": 'proof',
        "type": 'bytes',
      },
    ],
    "name": 'proveAndClaim',
    "outputs": [],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'name',
        "type": 'bytes',
      },
      {
        "components": [
          {
            "name": 'rrset',
            "type": 'bytes',
          },
          {
            "name": 'sig',
            "type": 'bytes',
          },
        ],
        "name": 'input',
        "type": 'tuple[]',
      },
      {
        "name": 'proof',
        "type": 'bytes',
      },
      {
        "name": 'resolver',
        "type": 'address',
      },
      {
        "name": 'addr',
        "type": 'address',
      },
    ],
    "name": 'proveAndClaimWithResolver',
    "outputs": [],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
];
