import "dart:math" as math;
import 'package:async_redux_project_template/_EXPORT.dart';

class Base62 {
  //
  static const base = 62;

  static const String numbers = "0123456789";
  static const String letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
  static const String charset = numbers + letters;

  /// Convert [numBase10] to base 62, with [length] characters.
  /// If [length] is null, it ignores the size issue.
  /// If [numBase10/ is null, it returns a String containing "0",
  /// and the number of zeros in the String will be equal to length,
  /// unless length is null, returning only a zero in this case.
  ///
  /// Throws [FormatException] if:
  ///  * `length` is zero.
  ///  * `length` is negative.
  ///  * `numBase10` is negative.
  ///  * The number in base 62 does not fit the `length`.
  ///
  static String convertToBase62(
    int numBase10, {
    String charset = charset,
    int? length,
  }) {
    if ((length != null) && (length <= 0)) throw const FormatException();
    if (numBase10 < 0) throw const FormatException();
    // ---

    if (numBase10 == 0) {
      return "0";
    }
    //
    else {
      final numBase62 = _convertToBase62(numBase10, charset);

      if (length == null) {
        return numBase62;
      }
      //
      else {
        if (numBase62.length > length)
          throw const FormatException();
        else
          return numBase62.padLeft(length, "0");
      }
    }
  }

  static String _convertToBase62(int numBase10, String charset) {
    //
    final chars = <String>[];

    while (numBase10 > 0) {
      final remainder = numBase10 % base;
      chars.add(charset[remainder]);
      numBase10 = numBase10 ~/ base;
    }

    return chars.reversed.join('');
  }

  /// Convert [numBase62] to base 10.
  ///
  /// Throws [FormatException] if:
  ///   * `numBase62` is empty.
  ///   * `numBase62` has an invalid char.
  ///
  static int convertToBase10(String numBase62, [String charset = charset]) {
    if (numBase62.isNullOrEmpty) throw const FormatException();
    // ---

    final numLength = numBase62.length;
    int numBase10 = 0;

    for (int i = 0; i < numLength; i++) {
      final char = numBase62[i];
      final index = charset.indexOf(char);
      if (index == -1) throw const FormatException();
      final potency = numLength - (i + 1);
      numBase10 += index * (math.pow(base, potency) as int);
    }

    return numBase10;
  }

  /// The [extra] chars will also be accepted, if any.
  static bool ifHasOnlyBase62Chars(String texto, {String extra = ""}) =>
      texto.split("").every((char) => charset.contains(char) || extra.contains(char));

  static bool seTemCharNaoBase62(String texto, {String extra = ""}) =>
      !ifHasOnlyBase62Chars(texto, extra: extra);

  /// Given a hash composed by a list of bytes (integers between 0 and 255 only),
  /// first does a mod 62, and then convert to base62. Note this method looses information,
  /// and as such can't be reverted. It should be used in hashes only.
  /// Also, since 62 is NOT a multiple of 256, there will be a small bias in the distribution
  /// (it will not be an uniform distribution).
  ///
  static String convertHashToBase62(List<int> bytes, {int? numChars}) {
    //
    final buffer = StringBuffer();

    /// If numChars was not defined, process the whole list.
    /// If there is numChars, limits to the list size.
    numChars = (numChars == null) ? bytes.length : math.min(numChars, bytes.length);

    /// Doing like this, the distribution is not perfect anymore, because 256 is not a multiple of 62.
    /// The first 6 chars will appear more frequently.
    for (int i = 0; i < numChars; i++) {
      var char = bytes[i];
      buffer.write(charset[char % base]);
    }

    return buffer.toString();
  }
}
