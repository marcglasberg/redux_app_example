import 'package:async_redux_project_template/_EXPORT.dart';
import "package:meta/meta.dart";



abstract class WithId<I extends Id> {
  I get pegaId;
}



/// An Id has at least 1, and at most 60 chars Base62.
/// - Random id: [Id.any]
/// - Id from String: `Id(uid)`
@immutable
class Id implements Comparable<Id> {
  //
  static const maxChars = 60;

  final String uid;

  const Id(this.uid)
      : assert(uid != ""),
        assert(uid.length <= maxChars, "Invalid Id.");

  static Id? orNull(String? uid) => (uid == null) ? null : Id(uid);

  factory Id.valid(String uid) {
    if (uid.isEmpty) throw ValidateError("Empty Id.");
    if (uid.length > maxChars) throw ValidateError("Invalid Id.");
    return Id(uid);
  }

  static Id get any => Id(Crypto.anyUid());

  static void checkIdValid(String uid) {
    //
    if (uid.isEmpty || uid.length > Id.maxChars)
      throw ValidateError("Invalid Id size (${uid.length}).");

    if (Base62.seTemCharNaoBase62(uid)) throw ValidateError("Invalid Id.");
  }

  static bool ifUidValid(String uid) {
    if (uid.isEmpty || uid.length > Id.maxChars)
      return false;
    else if (Base62.seTemCharNaoBase62(uid))
      return false;
    else
      return true;
  }

  @override
  String toString() => uid;

  /// Returns an integer number, calculated from the id.
  /// This may be used as a semi-random-but-consistent number.
  /// Note this number has no cryptographic property, and even does away with the id's uniqueness.
  int getAsInt() {
    int result = 0;
    for (int i = 0; i < uid.length; i++) {
      result += uid.codeUnitAt(i);
    }
    return result;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Id && (uid == other.uid);

  @override
  int get hashCode => uid.hashCode;

  @override
  int compareTo(Id other) => uid.compareTo(other.uid);
}



extension IdExtension on List<Id> {
  //
  List<String> get uids => map((id) => id.uid).toList();
}


