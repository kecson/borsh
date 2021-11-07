import 'package:meta/meta_meta.dart';

import 'borsh_field.dart';

/// An annotation used to specify how a field is serialized.
@Target({TargetKind.classType})
class BorshStruct {
  final BorshGetter? fromBorsh;
  final BorshSetter? toBorsh;

  const BorshStruct({this.fromBorsh, this.toBorsh});
}
