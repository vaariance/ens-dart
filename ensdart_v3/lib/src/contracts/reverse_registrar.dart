part of 'contracts.dart';

class ReverseRegistrar implements ContractInterfaceBase {
  @override
  String get name => "ReverseRegistrar";

  @override
  EthereumAddress? get address => null;

  @override
  ContractAbi get abi =>
      ContractAbi.fromJson(_reverseRegistrarAbi.toString(), name);

  @override
  String? get bytecode => null;

  @override
  String? get deployedBytecode => null;
}

final _reverseRegistrarAbi = [
  {
    "inputs": [
      {
        "name": 'addr',
        "type": 'address',
      },
      {
        "name": 'owner',
        "type": 'address',
      },
      {
        "name": 'resolver',
        "type": 'address',
      },
      {
        "name": 'name',
        "type": 'string',
      },
    ],
    "name": 'setNameForAddr',
    "outputs": [
      {
        "name": '',
        "type": 'bytes32',
      },
    ],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'name',
        "type": 'string',
      },
    ],
    "name": 'setName',
    "outputs": [
      {
        "name": '',
        "type": 'bytes32',
      },
    ],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
];
