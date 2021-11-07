import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';

import 'serialization.dart';

class BinaryWriter {
  final WriteBuffer _buffer = WriteBuffer();

  void writeU8(int value) => _buffer.putUint8(value);

  void writeFloat64(double value) => _buffer.putFloat64(value);

  void writeU16(int value) => _buffer.putUint16(value, endian: Endian.little);

  void writeU32(int value) => _buffer.putUint32(value, endian: Endian.little);

  void writeU64(int value) => _writeBigInt(BigInt.from(value));

  void writeU128(BigInt value) => _writeBigInt(value);

  void writeU256(BigInt value) => _writeBigInt(value);

  void writeU512(BigInt value) => _writeBigInt(value);

  void _writeBigInt(BigInt value) {
    var hexStr = value.toRadixString(16);
    var decode = hex.decode(hexStr);
    writeBuffer(Uint8List.fromList(decode));
  }

  void writeBuffer(Uint8List buf) => _buffer.putUint8List(buf);

  void writeString(String string) {
    var encode = utf8.encode(string);
    writeU32(encode.length);
    writeBuffer(Uint8List.fromList(encode));
  }

  void writeArray(List list, Function fn) {
    writeU32(list.length);
    for (var elem in list) {
      fn(elem);
    }
  }

  ByteData toArray() => _buffer.done();
}
