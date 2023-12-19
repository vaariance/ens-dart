import 'package:web3dart/web3dart.dart';

abstract class ContractInterfaceBase {
  String get name;
  EthereumAddress? get address;
  ContractAbi get abi;
  String? get bytecode;
  String? get deployedBytecode;
}
