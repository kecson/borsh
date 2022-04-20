import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../borsh.dart';
import 'binary_reader.dart';

class BorshError extends Error {
  final String message;

  BorshError(this.message);

  @override
  String toString() => '$message';
}

///see: https://github.com/near/borsh
class BorshCodec {
  final StructInfo structInfo;

  /// Creates a [MessageCodec] using the Flutter standard binary encoding.
  const BorshCodec(this.structInfo);

  Uint8List? encode(Map<String, dynamic>? json) {
    if (json == null) return null;
    BinaryWriter writer = BinaryWriter();
    _serializeStruct(structInfo, json, writer);
    return writer.toArray();
  }

  Map<String, dynamic> decode(ByteData? data) {
    if (data == null) return {};
    final reader = BinaryReader.byteData(data);
    return _decodeFromReader(reader);
  }

  Map<String, dynamic> decodeBuffer(ByteBuffer? byteBuffer) {
    if (byteBuffer == null) return {};
    final reader = BinaryReader.byteBuffer(byteBuffer);
    return _decodeFromReader(reader);
  }

  Map<String, dynamic> _decodeFromReader(BinaryReader reader) {
    var result = _deserializeStruct(structInfo, reader);
    return result;
  }

  void _serializeField(Field field, dynamic fieldValue, BinaryWriter writer) {
    //serialize Struct
    if (field is StructInfo) {
      _serializeStruct(field, fieldValue, writer);
      return;
    }
    if (field is ListInfo) {
      List list = fieldValue ?? [];
      if (field.isOption) {
        if (list.isEmpty) {
          writer.writeU8(0);
        } else {
          writer.writeU8(1);
          writer.writeArray(list, (elem) {
            _serializeField(field.struct, elem, writer);
          });
        }
      } else {
        writer.writeArray(
            list, (elem) => _serializeField(field.struct, elem, writer));
      }
      return;
    }
    if (field is! FieldInfo) {
      throw BorshError('Unexpected field: $field');
    }
    var handled = field.onFieldWrite?.call(writer, fieldValue) ?? false;
    if (handled) return;

    switch (field.type) {
      case FieldType.u8:
        writer.writeU8(fieldValue);
        break;
      case FieldType.u16:
        writer.writeU16(fieldValue);
        break;
      case FieldType.u32:
        writer.writeU32(fieldValue);

        break;
      case FieldType.u64:
        writer.writeU64(fieldValue);

        break;
      case FieldType.u128:
        writer.writeU128(fieldValue);

        break;
      case FieldType.u256:
        writer.writeU256(fieldValue);

        break;
      case FieldType.u512:
        writer.writeU512(fieldValue);

        break;
      case FieldType.Float64:
        writer.writeFloat64(fieldValue);
        break;
      case FieldType.String:
        writer.writeString(fieldValue);
        break;
      case FieldType.List:
        break;
    }
  }

  void _serializeStruct(
      StructInfo struct, Map<String, dynamic> obj, BinaryWriter writer) {
    for (var field in struct.schema) {
      var fieldValue = obj[field.name];
      _serializeField(field, fieldValue, writer);
    }
  }

  dynamic _deserializeField(Field field, BinaryReader reader) {
    //deserialize Struct
    if (field is StructInfo) {
      if (field.isOption) {
        var option = (reader.readU8() == 1);
        if (!option) {
          return {};
        }
      }
      return _deserializeStruct(field, reader);
    }

    if (field is ListInfo) {
      if (field.isOption) {
        var option = (reader.readU8() == 1);
        if (!option) {
          return [];
        }
      }
      var array =
          reader.readArray(() => _deserializeField(field.struct, reader));
      return array;
    }

    if (field.isOption) {
      var option = (reader.readU8() == 1);
      if (!option) {
        return null;
      }
    }

    if (field is! FieldInfo) {
      throw BorshError('Unexpected field: $field');
    }
    //deserialize Field
    var value = field.onFieldRead?.call(reader);
    if (null != value) return value;
    switch (field.type) {
      case FieldType.u8:
        value ??= reader.readU8();
        break;
      case FieldType.u16:
        value ??= reader.readU16();
        break;
      case FieldType.u32:
        value ??= reader.readU32();
        break;
      case FieldType.u64:
        value ??= reader.readU64();
        break;
      case FieldType.u128:
        value ??= reader.readU128();
        break;
      case FieldType.u256:
        value ??= reader.readU256();
        break;
      case FieldType.u512:
        value ??= reader.readU512();
        break;
      case FieldType.Float64:
        value ??= reader.readFloat64();
        break;
      case FieldType.String:
        value ??= reader.readString();
        break;
      case FieldType.List:
        break;
    }

    return value;
  }

  Map<String, dynamic> _deserializeStruct(Field field, BinaryReader reader) {
    if (field is StructInfo) {
      var result = <String, dynamic>{};
      for (var field in field.schema) {
        result[field.name] = _deserializeField(field, reader);
      }
      return result;
    } else {
      throw BorshError('Unexpected field : ${field.runtimeType}');
    }
  }
}
