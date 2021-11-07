import 'package:meta/meta_meta.dart';

import '../borsh.dart';
import 'binary_writer.dart';

typedef ValueGetter<T> = T Function();

/// Read value from borsh buffer.
///* [reader] borsh buffer
typedef BorshGetter = dynamic Function(BinaryReader reader);

/// Write [value] to borsh buffer.
/// * [writer] borsh buffer
/// * [value] Field value.
typedef BorshSetter = bool Function(BinaryWriter writer, dynamic value);

/// An annotation used to specify how a field is serialized.
@Target({TargetKind.field})
class BorshField {
  final BorshGetter? fromBorsh;
  final BorshSetter? toBorsh;

  final bool isOption;

  const BorshField({this.fromBorsh, this.toBorsh, this.isOption = false});
}
