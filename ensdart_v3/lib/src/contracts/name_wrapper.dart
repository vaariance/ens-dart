part of 'contracts.dart';

class NameWrapper implements ContractInterfaceBase {
  @override
  String get name => "NameWrapper";

  @override
  EthereumAddress? get address => null;

  @override
  ContractAbi get abi => ContractAbi.fromJson(_nameWrapperAbi.toString(), name);

  @override
  String? get bytecode => null;

  @override
  String? get deployedBytecode => null;
}

final _nameWrapperAbi = [
  {
    "inputs": [],
    "name": 'CannotUpgrade',
    "type": 'error',
  },
  {
    "inputs": [],
    "name": 'IncompatibleParent',
    "type": 'error',
  },
  {
    "inputs": [
      {
        "name": 'owner',
        "type": 'address',
      },
    ],
    "name": 'IncorrectTargetOwner',
    "type": 'error',
  },
  {
    "inputs": [],
    "name": 'IncorrectTokenType',
    "type": 'error',
  },
  {
    "inputs": [
      {
        "name": 'labelHash',
        "type": 'bytes32',
      },
      {
        "name": 'expectedLabelhash',
        "type": 'bytes32',
      },
    ],
    "name": 'LabelMismatch',
    "type": 'error',
  },
  {
    "inputs": [
      {
        "name": 'label',
        "type": 'string',
      },
    ],
    "name": 'LabelTooLong',
    "type": 'error',
  },
  {
    "inputs": [],
    "name": 'LabelTooShort',
    "type": 'error',
  },
  {
    "inputs": [],
    "name": 'NameIsNotWrapped',
    "type": 'error',
  },
  {
    "inputs": [
      {
        "name": 'node',
        "type": 'bytes32',
      },
    ],
    "name": 'OperationProhibited',
    "type": 'error',
  },
  {
    "inputs": [
      {
        "name": 'node',
        "type": 'bytes32',
      },
      {
        "name": 'addr',
        "type": 'address',
      },
    ],
    "name": 'Unauthorised',
    "type": 'error',
  },
  {
    "inputs": [
      {
        "name": 'id',
        "type": 'uint256',
      },
    ],
    "name": 'getData',
    "outputs": [
      {
        "name": 'owner',
        "type": 'address',
      },
      {
        "name": 'fuses',
        "type": 'uint32',
      },
      {
        "name": 'expiry',
        "type": 'uint64',
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
        "name": 'ownerControlledFuses',
        "type": 'uint16',
      },
    ],
    "name": 'setFuses',
    "outputs": [
      {
        "name": '',
        "type": 'uint32',
      },
    ],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'parentNode',
        "type": 'bytes32',
      },
      {
        "name": 'labelhash',
        "type": 'bytes32',
      },
      {
        "name": 'fuses',
        "type": 'uint32',
      },
      {
        "name": 'expiry',
        "type": 'uint64',
      },
    ],
    "name": 'setChildFuses',
    "outputs": [],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'parentNode',
        "type": 'bytes32',
      },
      {
        "name": 'label',
        "type": 'string',
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
      {
        "name": 'fuses',
        "type": 'uint32',
      },
      {
        "name": 'expiry',
        "type": 'uint64',
      },
    ],
    "name": 'setSubnodeRecord',
    "outputs": [
      {
        "name": 'node',
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
  {
    "inputs": [
      {
        "name": 'parentNode',
        "type": 'bytes32',
      },
      {
        "name": 'label',
        "type": 'string',
      },
      {
        "name": 'owner',
        "type": 'address',
      },
      {
        "name": 'fuses',
        "type": 'uint32',
      },
      {
        "name": 'expiry',
        "type": 'uint64',
      },
    ],
    "name": 'setSubnodeOwner',
    "outputs": [
      {
        "name": 'node',
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
        "type": 'bytes',
      },
      {
        "name": 'wrappedOwner',
        "type": 'address',
      },
      {
        "name": 'resolver',
        "type": 'address',
      },
    ],
    "name": 'wrap',
    "outputs": [],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'parentNode',
        "type": 'bytes32',
      },
      {
        "name": 'labelhash',
        "type": 'bytes32',
      },
      {
        "name": 'controller',
        "type": 'address',
      },
    ],
    "name": 'unwrap',
    "outputs": [],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": 'labelhash',
        "type": 'bytes32',
      },
      {
        "name": 'registrant',
        "type": 'address',
      },
      {
        "name": 'controller',
        "type": 'address',
      },
    ],
    "name": 'unwrapETH2LD',
    "outputs": [],
    "stateMutability": 'nonpayable',
    "type": 'function',
  },
  {
    "inputs": [
      {
        "name": '',
        "type": 'bytes32',
      },
    ],
    "name": 'names',
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
        "name": 'from',
        "type": 'address',
      },
      {
        "name": 'to',
        "type": 'address',
      },
      {
        "name": 'id',
        "type": 'uint256',
      },
      {
        "name": 'amount',
        "type": 'uint256',
      },
      {
        "name": 'data',
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
];
