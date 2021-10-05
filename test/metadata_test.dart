import 'dart:convert';
import 'dart:typed_data';

import 'package:borsh/borsh.dart';
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';

import 'raw_data.dart';

bool boolValueGetter(BinaryReader reader) {
  var value = reader.readU8() == 1;
  return value;
}

bool onBoolWrite(BinaryWriter writer, dynamic value) {
  writer.writeU8(value ? 1 : 0);
  return true;
}

String onPubKeyRead(BinaryReader reader) {
  var buf = reader.readBuffer(32);
  return hex.encode(buf);
}

bool onPubKeyWrite(BinaryWriter writer, dynamic value) {
  var buf = hex.decode(value);
  writer.writeBuffer(Uint8List.fromList(buf));
  return true;
}

final CREATOR_SCHEMA = StructInfo(
  name: 'Creator',
  schema: [
    FieldInfo(
      name: 'address',
      type: FieldType.List,
      onFieldRead: onPubKeyRead,
      onFieldWrite: onPubKeyWrite,
    ),
    FieldInfo(name: 'verified', type: FieldType.u8),
    FieldInfo(name: 'share', type: FieldType.u8),
  ],
);

final DATA_SCHEMA = StructInfo(
  name: 'Data',
  schema: [
    FieldInfo(name: 'name', type: FieldType.String),
    FieldInfo(name: 'symbol', type: FieldType.String),
    FieldInfo(name: 'uri', type: FieldType.String),
    FieldInfo(name: 'sellerFeeBasisPoints', type: FieldType.u16),
    ListInfo(
      name: 'creators',
      isOption: true,
      struct: StructInfo(
        name: 'Creator',
        schema: CREATOR_SCHEMA.schema,
      ),
    )
  ],
);

final METADATA_SCHEMA = StructInfo(
  name: 'Metadata',
  schema: [
    FieldInfo(name: 'key', type: FieldType.u8),
    FieldInfo(
      name: 'updateAuthority',
      type: FieldType.List,
      onFieldRead: onPubKeyRead,
      onFieldWrite: onPubKeyWrite,
    ),
    FieldInfo(
      name: 'mint',
      type: FieldType.List,
      onFieldRead: onPubKeyRead,
      onFieldWrite: onPubKeyWrite,
    ),
    StructInfo(name: 'data', schema: DATA_SCHEMA.schema),
    FieldInfo(name: 'primarySaleHappened', type: FieldType.u8),
    FieldInfo(name: 'isMutable', type: FieldType.u8),
  ],
);

void main() async {
  var base64data =
      'BGmO2ktOSsf3Amy0BZ7duZg6Pk69jbyCAikmyylt2seGAEPfCAi8McYzvjO7VUqIe+xRbGwOTEBMHbg5g2OiB0wgAAAAU29sQmVhcgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKAAAAQkVBUgAAAAAAAMgAAABodHRwczovL2lwZnMuaW8vaXBmcy9RbVMyQlplY2dUTTVqeTFQV3pGYnhjUDZqRHNMb3E1RWJHTm1td0NQYmk3WU5ILzYzMDkuanNvbgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAf8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==';
  var buffer = Uint8List.fromList(encodeData).buffer;
  // var buffer = Uint8List.fromList(base64.decode(base64data)).buffer;
  var borshCodec = BorshCodec(METADATA_SCHEMA);
  var metadataMap = borshCodec.decode(buffer.asByteData());
  print('${json.encode(metadataMap)}');

  var message = borshCodec.encode(metadataMap);
  var decodeData = borshCodec.decode(message);

  var uint8list = message!.buffer.asUint8List();
  var compare =
  listEquals(uint8list, encodeData.sublist(0, uint8list.lengthInBytes));
  assert(compare);
}
