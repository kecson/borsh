import 'package:borsh/borsh.dart';

void main() {
  final map = {
    'name': 'Borsh',
    'x': 123,
    'y': 25.235678,
    'z': '1234',
    'list': [
      {'id': 1, 'language': 'Dart'},
      {'id': 2, 'language': 'Java'},
      {'id': 3, 'language': 'Python'},
      {'id': 4, 'language': 'Kotlin'},
    ],
  };
  var schema = StructInfo(
    name: 'struct',
    schema: [
      FieldInfo(name: 'name', type: FieldType.String),
      FieldInfo(name: 'x', type: FieldType.u8),
      FieldInfo(name: 'y', type: FieldType.Float64),
      FieldInfo(name: 'z', type: FieldType.String),
      ListInfo(
        name: 'list',
        struct: StructInfo(
          name: '',
          schema: [
            FieldInfo(name: 'id', type: FieldType.u8),
            FieldInfo(name: 'language', type: FieldType.String),
          ],
        ),
      ),
    ],
  );

  var borshCodec = BorshCodec(schema);
  var encode = borshCodec.encode(map);
  var decode = borshCodec.decode(encode);
  print(decode);
}
