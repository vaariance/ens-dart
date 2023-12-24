part of 'contracts.dart';

class Registry implements ContractInterfaceBase {
  @override
  String get name => "Registry";

  @override
  EthereumAddress? get address => null;

  @override
  ContractAbi get abi => ContractAbi.fromJson(_registry.toString(), name);

  @override
  String? get bytecode => null;

  @override
  String? get deployedBytecode => null;
}

final _registry = [
  {
    "inputs": [
      {
        "name": 'node',
        "type": 'bytes32',
      },
    ],
    "name": 'owner',
    "outputs": [
      {
        "name": '',
        "type": 'address',
      },
    ],
    "stateMutability": 'view',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'node',
        "type": 'bytes32',
      },
      {
        "name": 'label',
        "type": 'bytes32',
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
        "name": 'ttl',
        "type": 'uint64',
      },
    ],
    "name": 'setSubnodeRecord',
    "outputs": [],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'node',
        "type": 'bytes32',
      },
    ],
    "name": 'resolver',
    "outputs": [
      {
        "name": '',
        "type": 'address',
      },
    ],
    "stateMutability": 'view',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'operator',
        "type": 'address',
      },
      {
        "name": 'approved',
        "type": 'bool',
      },
    ],
    "name": 'setApprovalForAll',
    "outputs": [],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'node',
        "type": 'bytes32',
      },
      {
        "name": 'resolver',
        "type": 'address',
      },
    ],
    "name": 'setResolver',
    "outputs": [],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'node',
        "type": 'bytes32',
      },
      {
        "name": 'owner',
        "type": 'address',
      },
    ],
    "name": 'setOwner',
    "outputs": [],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'node',
        "type": 'bytes32',
      },
      {
        "name": 'label',
        "type": 'bytes32',
      },
      {
        "name": 'owner',
        "type": 'address',
      },
    ],
    "name": 'setSubnodeOwner',
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
        "name": 'node',
        "type": 'bytes32',
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
        "name": 'ttl',
        "type": 'uint64',
      },
    ],
    "name": 'setRecord',
    "outputs": [],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
];
