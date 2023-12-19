part of 'contracts.dart';

class ERC721 implements ContractInterfaceBase {
  @override
  String get name => "ERC721";

  @override
  EthereumAddress? get address => null;

  @override
  ContractAbi get abi => ContractAbi.fromJson(_erc721Abi.toString(), name);

  @override
  String? get bytecode => null;

  @override
  String? get deployedBytecode => null;
}

final _erc721Abi = [
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
];
