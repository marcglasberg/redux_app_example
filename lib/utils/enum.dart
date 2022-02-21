import 'package:async_redux_project_template/_EXPORT.dart';
import 'package:flutter/foundation.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////

/// This is useful while we way for:
/// * https://github.com/dart-lang/language/issues/158
/// When the above issue is implemented we'll change this:
/// `UpDown.values.fromOrNull(map['extUpDown'])`
/// into this: `UpDown.fromOrNull(map['extUpDown'])`
extension EnumExtension<T> on List<T> {
  //
  T from(String value) => firstWhere(
        (T e) {
          //
          if (e is Enum) {
            return describeEnum(e).replaceAll("_", "").toUpperCase() ==
                value.replaceAll("_", "").toUpperCase();
          }
          //
          else if (e is Enumerator) {
            return e.id.uid.replaceAll("_", "").toUpperCase() ==
                value.replaceAll("_", "").toUpperCase();
          }
          //
          else
            throw ValidateError('${e.runtimeType} is not Enum or Enumerator.');
        },
        orElse: () => throw ValidateError('Enum "$T.$value" does not exist.'),
      );

  T? fromOrNull(String? value) => (value == null) ? null : from(value);
}

// TODO: DONT REMOVE
// extension EnumExtension<T extends Enum> on List<T> {
//   //
//   T from(String value) => firstWhere(
//         (T e) =>
//     describeEnum(e).replaceAll("_", "").toUpperCase() ==
//         value.replaceAll("_", "").toUpperCase(),
//     orElse: () => throw AssertionError('Enum "$T.$value" does not exist.'),
//   );
//
//   T? fromOrNull(String? value) => (value == null) ? null : from(value);
// }

////////////////////////////////////////////////////////////////////////////////////////////////////

abstract class Enumerator {
  //
  const Enumerator(this.id);

  final Id id;

  @override
  String toString() => "$runtimeType.$id";

  bool ifItsOneOf<E extends Enumerator>(List<E> enums) => enums.any((_enum) => _enum == this);

  /// The text description, translated to the current locale.
  String text() => throw AssertionError(this);

  /// The text long description, translated to the current locale.
  String subText() => throw AssertionError(this);

  /// Description for BDDs.
  Object? describe() => id;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class EnumError extends Error {
  final Enumerator enumerator;

  EnumError(this.enumerator);

  @override
  String toString() => "Enum error: ${enumerator.toString()}";
}

////////////////////////////////////////////////////////////////////////////////////////////////////
