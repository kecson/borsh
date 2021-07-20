import 'package:borsh/borsh.dart';

enum SchemaKind {
  // Enum,
  List,
  Struct,
  Option,
}

enum FieldType {
  ///num
  u8,
  u16,
  u32,

  ///BigInt
  u64,
  u128,
  u256,
  u512,
  Float64,

  //
  List,
  String,
}

abstract class Field {
  final String name;
  final OnFieldRead? onFieldRead;
  final OnFieldWrite? onFieldWrite;
  final bool isOption;

  const Field({
    required this.name,
    this.onFieldRead,
    this.onFieldWrite,
    this.isOption = false,
  });
}

typedef OnFieldRead = dynamic Function(BinaryReader reader);
typedef OnFieldWrite = bool Function(BinaryWriter writer, dynamic value);

class FieldInfo extends Field {
  final FieldType type;

  const FieldInfo({
    required String name,
    required this.type,
    OnFieldRead? onFieldRead,
    OnFieldWrite? onFieldWrite,
    bool isOption = false,
  }) : super(
          name: name,
          onFieldRead: onFieldRead,
          onFieldWrite: onFieldWrite,
          isOption: isOption,
        );
}

class StructInfo extends Field {
  final List<Field> schema;

  const StructInfo({
    required String name,
    required this.schema,
    OnFieldRead? onFieldRead,
    OnFieldWrite? onFieldWrite,
    bool isOption = false,
  }) : super(
          name: name,
          onFieldRead: onFieldRead,
          onFieldWrite: onFieldWrite,
          isOption: isOption,
        );
}

class ListInfo extends Field {
  final StructInfo struct;

  ListInfo({
    required String name,
    required this.struct,
    bool isOption = false,
  }) : super(
          name: name,
          onFieldRead: null,
          onFieldWrite: null,
          isOption: isOption,
        );
}
