part of 'contracts.dart';

class PublicResolver implements ContractInterfaceBase {
  @override
  String get name => "PublicResolver";

  @override
  EthereumAddress? get address => null;

  @override
  ContractAbi get abi =>
      ContractAbi.fromJson(_publicResolverAbi.toString(), name);

  @override
  String? get bytecode => null;

  @override
  String? get deployedBytecode => null;
}

final _publicResolverAbi = [
  {
    "inputs": [
      {
        "name": 'node',
        "type": 'bytes32',
      },
    ],
    "name": 'addr',
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
        "name": 'coinType',
        "type": 'uint256',
      },
    ],
    "name": 'addr',
    "outputs": [
      {
        "name": '',
        "type": 'bytes',
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
        "name": 'key',
        "type": 'string',
      },
    ],
    "name": 'text',
    "outputs": [
      {
        "name": '',
        "type": 'string',
      },
    ],
    "stateMutability": 'view',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "internalType": 'bytes32',
        "name": 'node',
        "type": 'bytes32',
      },
    ],
    "name": 'contenthash',
    "outputs": [
      {
        "internalType": 'bytes',
        "name": '',
        "type": 'bytes',
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
        "name": 'contentTypes',
        "type": 'uint256',
      },
    ],
    "name": 'ABI',
    "outputs": [
      {
        "name": '',
        "type": 'uint256',
      },
      {
        "name": '',
        "type": 'bytes',
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
        "name": 'key',
        "type": 'string',
      },
      {
        "name": 'value',
        "type": 'string',
      },
    ],
    "name": 'setText',
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
        "name": 'coinType',
        "type": 'uint256',
      },
      {
        "name": 'a',
        "type": 'bytes',
      },
    ],
    "name": 'setAddr',
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
        "name": 'contentType',
        "type": 'uint256',
      },
      {
        "name": 'data',
        "type": 'bytes',
      },
    ],
    "name": 'setABI',
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
        "name": 'hash',
        "type": 'bytes',
      },
    ],
    "name": 'setContenthash',
    "outputs": [],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "internalType": 'bytes32',
        "name": 'node',
        "type": 'bytes32',
      },
    ],
    "name": 'clearRecords',
    "outputs": [],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'data',
        "type": 'bytes[]',
      },
    ],
    "name": 'multicall',
    "outputs": [
      {
        "name": 'results',
        "type": 'bytes[]',
      },
    ],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
];
