import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'borsh_codec.dart';

class BinaryReader {
  final ReadBuffer buffer;

  const BinaryReader(this.buffer);

  BinaryReader.byteData(ByteData byteData) : this(ReadBuffer(byteData));

  BinaryReader.byteBuffer(ByteBuffer buffer)
      : this.byteData(buffer.asByteData());

  int readU8() => buffer.getUint8();

  double readFloat64() => buffer.getFloat64();

  int readU16() => buffer.getUint16();

  int readU32() => buffer.getUint32();

  BigInt readU64() {
    var buf = readBuffer(8);
    var hex = buf.fold('', (pre, e) => '$pre${e.toRadixString(16)}');
    return BigInt.parse(hex, radix: 16);
  }

  BigInt readU128() {
    var buf = readBuffer(16);
    var hex = buf.fold('', (pre, e) => '$pre${e.toRadixString(16)}');
    return BigInt.parse(hex, radix: 16);
  }

  BigInt readU256() {
    var buf = readBuffer(32);
    var hex = buf.fold('', (pre, e) => '$pre${e.toRadixString(16)}');
    return BigInt.parse(hex, radix: 16);
  }

  BigInt readU512() {
    var buf = readBuffer(64);
    var hex = buf.fold('', (pre, e) => '$pre${e.toRadixString(16)}');
    return BigInt.parse(hex, radix: 16);
  }

  Uint8List readBuffer(int length) => buffer.getUint8List(length);

  String readString() {
    final len = readU32();
    var buf = readBuffer(len);
    try {
      if (buf.isNotEmpty) {
        var index = buf.indexOf(0);
        if (index >= 0) {
          buf = buf.sublist(0, index);
        }
      }
      var decode = utf8.decode(buf);
      return decode;
    } catch (e) {
      throw BorshError('Error decoding UTF-8 string: $e');
    }
  }

  Uint8List readFixedArray(int length) => readBuffer(length);

  List readArray(ValueGetter fn) {
    final len = readU32();
    var result = [];
    for (var i = 0; i < len; ++i) {
      result.add(fn());
    }
    return result;
  }
}
