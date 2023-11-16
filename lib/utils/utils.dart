import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart' show numberFormatSymbols;

/// Given a locale, return the decimal separator.
/// For example, for en_US it's "." but for pt_BR it's ",".
String getDecimalSeparator() {
  //
  String language = Intl.getCurrentLocale();

  // TODO: MARCELO Another way of doing th is would be:
  // TODO: String language = I18n.locale.languageCode;
  // TODO: I believe I should improve the compatibility of I18n and Intl.

  NumberSymbols? x = numberFormatSymbols[language];
  return x?.DECIMAL_SEP ?? ".";
}

/// Given a locale, return the group separator.
/// For example, for en_US it's "," but for pt_BR it's ".".
String getGroupSeparator() {
  //
  String language = Intl.getCurrentLocale();

  // TODO: MARCELO Another way of doing this would be:
  // TODO: String language = I18n.locale.languageCode;
  // TODO: I believe I should improve the compatibility of I18n and Intl.

  NumberSymbols? x = numberFormatSymbols[language];
  return x?.GROUP_SEP ?? ",";
}

void vibrate() => HapticFeedback.vibrate();

/// Hides the buildCounter. Use it with TextFields: `buildCounter: textfieldBuildCounterDummy`
Widget? textfieldCounterDummy(BuildContext context,
        {int? currentLength, int? maxLength, bool? isFocused}) =>
    null;

@override
dynamic errorMsgForInvalidObj(Invocation invocation, Object obj) => throw AssertionError(
    'Tried to use invalid object \'${obj.runtimeType}\': ${invocation.memberName}.}');

extension StringExtensionNullable on String? {
  bool get isNullOrEmpty => (this == null) || this!.isEmpty;

  bool get isNullOrTrimmedEmpty => (this == null) || this!.trim().isEmpty;

  bool get isNotNullOrEmpty => (this != null) && this!.isNotEmpty;

  bool get isEmptyButNotNull => (this != null) && this!.isEmpty;

  bool get isNotNullOrTrimmedEmpty => (this != null) && this!.trim().isNotEmpty;
}

extension StringExtension on String {
  /// Puts non-break spaces in place of normal spaces.
  String get nonBreak => replaceAll(" ", "\u00A0");

  bool hasLength(List<int> lengths) => lengths.contains(length);

  String toUpperCaseIf(bool ifTrue) => ifTrue ? toUpperCase() : this;

  String lastChars(int numb) => substring((length - numb).clamp(0, length));

  /// If the string ends with [end], replace that end with [replacement].
  /// If the string does NOT ends with [end], return the unmodified string.
  String replaceEnd({required String end, required String replacement}) {
    if (endsWith(end)) {
      return substring(0, length - end.length) + replacement;
    } else
      return this;
  }

  static final _allSpaces = RegExp(r'[\s]');

  String removeSpaces() => replaceAll(_allSpaces, "");

  /// Those chars that satisfy the [test] will be kept. The rest will be removed.
  /// This uses the [Characters] lib.
  String keep(bool test(String char)) {
    var chars = Characters(this);

    // TODO: Could instead simply return:
    // TODO: return chars.where(test).toString();
    // TODO: But I found a bug: https://github.com/flutter/flutter/issues/87376
    return chars.toList().where(test).join();
  }

  /// Those chars that satisfy the [test] will be removed.
  /// This uses the [Characters] lib.
  String remove(bool test(String char)) => keep((char) => !test(char));

  /// Those chars that satisfy the [test] will be removed, except for the FIRST.
  /// In other works, it will leave only one (the first) occurrence.
  /// This uses the [Characters] lib.
  String removeButFirst(bool test(String char)) {
    bool foundFirst = false;
    bool _test(char) {
      var _test = test(char);
      var shouldKeep = !_test || !foundFirst;
      foundFirst = foundFirst || _test;
      return shouldKeep;
    }

    return keep(_test);
  }

  String onlyNumbers() =>
      keep((char) => const {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}.contains(char));

  String onlyNumbersAndDot() =>
      keep((char) => const {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."}.contains(char));

  String onlyNumbersAndDotAndMinus() => keep(
      (char) => const {"-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."}.contains(char));

  String onlyNumbersAndMinusAndCurrentDecimalSeparator() => keep((char) => {
        "-",
        "0",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        getDecimalSeparator(),
      }.contains(char));

  String onlyNumbersAndCurrentDecimalSeparator() => keep((char) => {
        "0",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        getDecimalSeparator(),
      }.contains(char));

  /// Example: "1,2,3,4" ➜ "1,234"
  String keepOnlyTheFirstDecimalSeparator() {
    var decimalSeparator = getDecimalSeparator();
    return removeButFirst((char) => char == decimalSeparator);
  }

  /// Gets the first `size` code-units of the string and ignores the remaining grapheme-clusters.
  ///
  /// Note this is necessary because the `substring` method may cut a grapheme-cluster in half,
  /// thus generating a different character from those in the original string.
  ///
  /// For example:
  ///
  /// ```dart
  /// assert('🥦'.length == 2);
  /// assert('🥦'.substring(0, 1) == '�');
  /// ```
  ///
  /// In other words: To avoid returning different or invalid chars, this method removes whole
  /// grapheme-clusters, preventing them to be cut in pieces.
  /// In the above example, an empty string would result.
  ///
  /// Se `size` is larger than  `string.length`, return the original string, unchanged.
  String cutsUnicode(int size) {
    // TODO: This is inefficient. Can be improved.
    var text = this;
    while (text.length > size) text = text.characters.skipLast(1).string;
    return text;
  }

  /// To iterate a [String]: `"Hello".iterable()`
  /// This will use simple characters. If you want to use Unicode Grapheme
  /// from the [Characters] library, pass [chars] true.
  Iterable<String> iterable({bool unicode = false}) sync* {
    if (unicode) {
      var iterator = Characters(this).iterator;
      while (iterator.moveNext()) {
        yield iterator.current;
      }
    } else
      for (var i = 0; i < length; i++) {
        yield this[i];
      }
  }

  /// Passe null to keep it unchanged.
  String capitalize(Capitalize? capitalize) {
    if (capitalize == null)
      return this;
    else if (capitalize == Capitalize.upper)
      return toUpperCase();
    else if (capitalize == Capitalize.lower)
      return toLowerCase();
    else if (capitalize == Capitalize.firstLetterUpper)
      return capitalizeFirstLetter(this);
    else
      throw AssertionError(capitalize);
  }

  static final _bannedSymbols = RegExp(
      r"[-|!|@|#|$|%|¨|&|*|(|)|_|+|`|{|}|^|:|?|>|<|,|.|;|/|~|´|=|°|º|ª|§|¹|²|³|£|¢|¬|\\|\|\]|\[|'|]");

  // 1) Removes spaces and similar.
  // 2) Removes banned symbols.
  // 3) Makes it uppercase.
  String normalize() => replaceAll(RegExp(r'\s+\b|\b\s|\b|\s|\"'), "")
      .replaceAll(_bannedSymbols, "")
      .replaceAll("\"", "")
      .toUpperCase();
}

enum Capitalize {
  firstLetterUpper, // All the others unchanged.
  upper, // All uppercase.
  lower, // All lowercase.
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty)
    return text;
  //
  else {
    var characters = Characters(text);
    return (characters.take(1).toUpperCase() + characters.skip(1)).string;
  }
}

dynamic getIn(List<String> path, Map<String, dynamic> map) {
  return path.fold(
      map,
      (previousValue, element) => (previousValue.runtimeType != Map)
          ? previousValue
          : (previousValue)[element]);
}
