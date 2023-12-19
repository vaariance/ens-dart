part of 'contracts.dart';

class BaseRegistrar implements ContractInterfaceBase {
  @override
  String get name => "BaseRegistrar";

  @override
  EthereumAddress? get address => null;

  @override
  ContractAbi get abi =>
      ContractAbi.fromJson(_baseRegistrarAbi.toString(), name);

  @override
  String? get bytecode => null;

  @override
  String? get deployedBytecode => null;
}

final _baseRegistrarAbi = [
  {
    "inputs": [
      {
        "name": 'id',
        "type": 'uint256',
      },
    ],
    "name": 'available',
    "outputs": [
      {
        "name": 'available',
        "type": 'bool',
      },
    ],
    "stateMutability": 'view',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'id',
        "type": 'uint256',
      },
    ],
    "name": 'nameExpires',
    "outputs": [
      {
        "name": '',
        "type": 'uint256',
      },
    ],
    "stateMutability": 'view',
    "type": 'function',
  },
  {
    "inputs": [],
    "name": 'GRACE_PERIOD',
    "outputs": [
      {
        "name": '',
        "type": 'uint256',
      },
    ],
    "stateMutability": 'view',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'id',
        "type": 'uint256',
      },
      {
        "name": 'owner',
        "type": 'address',
      },
    ],
    "name": 'reclaim',
    "outputs": [],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'from',
        "type": 'address',
      },
      {
        "name": 'to',
        "type": 'address',
      },
      {
        "name": 'tokenId',
        "type": 'uint256',
      },
    ],
    "name": 'safeTransferFrom',
    "outputs": [],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'from',
        "type": 'address',
      },
      {
        "name": 'to',
        "type": 'address',
      },
      {
        "name": 'tokenId',
        "type": 'uint256',
      },
      {
        "name": '_data',
        "type": 'bytes',
      },
    ],
    "name": 'safeTransferFrom',
    "outputs": [],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'id',
        "type": 'uint256',
      },
    ],
    "name": 'ownerOf',
    "outputs": [
      {
        "name": 'owner',
        "type": 'address',
      },
    ],
    "stateMutability": 'view',
    "type": 'function',
  },
];
