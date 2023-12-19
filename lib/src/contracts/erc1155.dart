part of 'contracts.dart';

class ERC1155 implements ContractInterfaceBase {
  @override
  String get name => "ERC1155";

  @override
  EthereumAddress? get address => null;

  @override
  ContractAbi get abi => ContractAbi.fromJson(_erc1155Abi.toString(), name);

  @override
  String? get bytecode => null;

  @override
  String? get deployedBytecode => null;
}

final _erc1155Abi = [
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
];
