// import "package:flutter/material.dart";
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////
//
// enum StyleType {
//   bold,
//   italic,
//   strikethrough,
//   underline,
//   smaller,
//   small,
//   tiny,
//   bigger,
//   big,
//   whatsapp,
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////
//
// /// The rules here try to imitate Whatsapp:
// ///   Formats bold text with "*" delimiter.
// ///   There MUST be a space before the first delimiter.
// ///   There MUST be a space or a dot after the last delimiter.
// ///   There must NOT be a space after the first delimiter.
// ///   There must NOT be a space before the last delimiter.
// class StyledText extends StatelessWidget {
//   //
//   final String text;
//
//   final TextAlign textAlign;
//
//   // The style for normal text.
//   final TextStyle style;
//
//   // The style for the text between asterisks.
//   final TextStyle alteredStyle;
//
//   final StyleType? styleType;
//
//   final Lazy<List<Range>> _boldRanges;
//
//   List<Range> get boldRanges => _boldRanges.value;
//
//   StyledText(
//     this.text, {
//     TextStyle? style,
//     this.textAlign = TextAlign.left,
//     this.styleType = StyleType.bold,
//   })  : _boldRanges = Lazy(() => _lazyBoldRanges(text, delimiter(styleType ?? StyleType.bold))),
//         alteredStyle = _alteredTextStyle(
//             styleType: styleType, style: style ?? const TextStyle(), alteredStyle: null),
//         style = style ?? const TextStyle();
//
//   StyledText.from(
//     this.text, {
//     this.textAlign = TextAlign.left,
//     required this.style,
//     required TextStyle alteredStyle,
//     delimiter = '*',
//   })  : _boldRanges = Lazy(() => _lazyBoldRanges(text, delimiter)),
//         alteredStyle = _alteredTextStyle(styleType: null, style: style, alteredStyle: alteredStyle),
//         styleType = null;
//
//   @override
//   Widget build(BuildContext context) {
//     //
//     if ((styleType == StyleType.whatsapp))
//       return WhatsAppStyledText(
//         text,
//         style: style,
//         textAlign: textAlign,
//       );
//     else
//       return RichText(
//         textAlign: textAlign,
//         textWidthBasis: TextWidthBasis.longestLine,
//         text: TextSpan(
//           style: style,
//           children: _getTextSpans(),
//         ),
//       );
//   }
//
//   static TextStyle _alteredTextStyle({
//     required StyleType? styleType,
//     required TextStyle style,
//     required TextStyle? alteredStyle,
//   }) {
//     if (styleType == null && alteredStyle != null)
//       return alteredStyle;
//     else if (styleType == StyleType.bold)
//       return const TextStyle(fontWeight: FontWeight.bold);
//     else if (styleType == StyleType.italic)
//       return const TextStyle(fontStyle: FontStyle.italic);
//     else if (styleType == StyleType.strikethrough)
//       return const TextStyle(decoration: TextDecoration.lineThrough);
//     else if (styleType == StyleType.underline)
//       return const TextStyle(decoration: TextDecoration.underline);
//     else if (styleType == StyleType.smaller)
//       return TextStyle(fontSize: style.fontSize! * 0.875);
//     else if (styleType == StyleType.small)
//       return TextStyle(fontSize: style.fontSize! * 0.80);
//     else if (styleType == StyleType.tiny)
//       return TextStyle(fontSize: style.fontSize! * 0.70);
//     else if (styleType == StyleType.big)
//       return TextStyle(fontSize: style.fontSize! * 1.2);
//     else
//       throw AssertionError();
//   }
//
//   static String delimiter(StyleType styledTextType) {
//     //
//     if (styledTextType == StyleType.bold)
//       return "*";
//     //
//     else if (styledTextType == StyleType.italic)
//       return "_";
//     //
//     else if (styledTextType == StyleType.strikethrough)
//       return "~";
//     //
//     else if (styledTextType == StyleType.underline)
//       return "_";
//     //
//     else if (styledTextType == StyleType.small ||
//         styledTextType == StyleType.smaller ||
//         styledTextType == StyleType.big ||
//         styledTextType == StyleType.bigger)
//       return "_";
//     //
//     else
//       throw AssertionError();
//   }
//
//   List<TextSpan> _getTextSpans() {
//     //
//     List<TextSpan> result = [];
//
//     var outOfRange =
//         (Range range, String text) => result.add(TextSpan(text: range.ofTextInclusive(text)));
//
//     var inRange = (Range range, String text) => result.add(TextSpan(
//           text: range.ofTextExclusive(text),
//           style: alteredStyle,
//         ));
//
//     RangeFormat(
//       text: text,
//       ranges: boldRanges,
//       outOfRange: outOfRange,
//       inRange: inRange,
//     ).process();
//
//     return result;
//   }
//
//   static List<Range> _lazyBoldRanges(String text, String delimiter) {
//     //
//     List<Range> ranges = [];
//
//     if (text.length >= 2) {
//       int? boldIni;
//
//       for (int i = 0; i < text.length; i++) {
//         var char = text[i];
//
//         if (char == delimiter) {
//           if (boldIni == null)
//             boldIni = i;
//           else {
//             ranges.add(Range(boldIni, i));
//             boldIni = null;
//           }
//         }
//       }
//     }
//
//     return ranges;
//   }
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////
//
// class Range {
//   final int ini;
//   final int fim;
//
//   const Range(this.ini, this.fim);
//
//   factory Range.fromList(List<int> items) {
//     if (items.length != 2) {
//       throw new ArgumentError('List must have length 2.');
//     }
//
//     return Range(items[0], items[1]);
//   }
//
//   /// A range is valid if it contains at least one char.
//   bool isValid() {
//     return ini <= fim && ini >= 0 && fim >= 0;
//   }
//
//   /// Returns a range with the first item set to the specified value.
//   Range withItem1(int v) {
//     return Range(v, fim);
//   }
//
//   /// Returns a range with the second item set to the specified value.
//   Range withItem2(int v) {
//     return Range(ini, v);
//   }
//
//   /// Creates a [List] containing the items of this [Range].
//   /// The elements are in item order. The list is variable-length if [growable] is true.
//   List toList({bool growable = false}) => new List<int>.from(<int>[ini, fim], growable: growable);
//
//   @override
//   String toString() => '[$ini, $fim]';
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is Range && runtimeType == other.runtimeType && ini == other.ini && fim == other.fim;
//
//   @override
//   int get hashCode => ini.hashCode ^ fim.hashCode;
//
//   /// TODO: MARCELO ➜ This doesn't work. Have to use the characters package.
//   /// The text, including chars ini and fim.
//   String ofTextInclusive(String text) {
//     return text.substring(ini, fim + 1);
//   }
//
//   /// TODO: MARCELO ➜ This doesn't work. Have to use the characters package.
//   /// The text, NOT including chars ini and fim.
//   String ofTextExclusive(String text) {
//     if (ini >= fim - 1)
//       return "";
//     else
//       return text.substring(ini + 1, fim);
//   }
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////
//
// class RangeFormat {
//   final String text;
//   final List<Range> ranges;
//   final Function(Range range, String text) outOfRange;
//   final Function(Range range, String text) inRange;
//
//   RangeFormat({
//     required this.text,
//     required this.ranges,
//     required this.outOfRange,
//     required this.inRange,
//   });
//
//   void process() {
//     if (ranges.isEmpty) {
//       _simple();
//       return;
//     }
//
//     _before(ranges[0]);
//
//     if (ranges.length >= 2) {
//       for (int i = 0; i < ranges.length - 1; i++) {
//         _between(ranges[i], ranges[i + 1]);
//       }
//     }
//
//     _after(ranges[ranges.length - 1]);
//   }
//
//   void _simple() {
//     outOfRange(Range(0, text.length - 1), text);
//   }
//
//   /// Process before the first range. Don't process the range itself.
//   void _before(Range firstRange) {
//     Range beforeFirst = Range(0, firstRange.ini - 1);
//
//     if (beforeFirst.isValid()) {
//       outOfRange(beforeFirst, text);
//     }
//   }
//
//   /// Process range 1 and between ranges. Don't process the range2.
//   void _between(Range range1, Range range2) {
//     inRange(range1, text);
//
//     Range betweenRanges = Range(range1.fim + 1, range2.ini - 1);
//
//     if (betweenRanges.isValid()) {
//       outOfRange(betweenRanges, text);
//     }
//   }
//
//   /// Process range 2 and after range2.
//   void _after(Range lastRange) {
//     inRange(lastRange, text);
//
//     Range afterLast = Range(lastRange.fim + 1, text.length - 1);
//
//     if (afterLast.isValid()) {
//       outOfRange(afterLast, text);
//     }
//   }
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////
//
// typedef _LazyCalculation<T> = T Function();
//
// /// StatelessWidget need to be final, or a warning will be shown.
// /// But sometimes we want to create lazy e effectively-final values (that are calculated
// /// only during the first time they are used, and after that are final).
// ///
// /// Example:
// ///  Declare:             final Lazy<Info> _info;
// ///  In the constructor:  _info = Lazy(() => _lazyInfo(text));
// ///  Getter:              Info get info => _info.value;
// ///
// class Lazy<T> {
//   final _LazyCalculation<T> _calculateFunction;
//   T? _value;
//
//   Lazy(_LazyCalculation<T> calculateFunction) : _calculateFunction = calculateFunction;
//
//   T get value {
//     _value ??= _calculateFunction();
//     return _value!;
//   }
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////
//
// /// Rules here try to imitate Whatsapp.
// class WhatsAppStyledText extends StatelessWidget {
//   //
//   final String? text;
//   final TextStyle? style;
//   final TextAlign textAlign;
//   final TextFormatter _textFormatter;
//
//   WhatsAppStyledText(
//     this.text, {
//     this.style,
//     this.textAlign = TextAlign.left,
//     //
//     // Pass true to underline instead of strike-through the text.
//     // Nota: Whatsapp default is strike-through, and you can't underline, maybe to not
//     // mistake it for a link.
//     bool seUsaUnderline = false,
//     //
//   }) : _textFormatter = WhatsAppTextFormatter(seUsaUnderline: seUsaUnderline);
//
//   /// Returns the text without formatting and without the formatting characters.
//   static String plaintext(String text) => _plaintextSpans(text).join();
//
//   @override
//   Widget build(BuildContext context) {
//     return RichText(
//       textAlign: textAlign,
//       textWidthBasis: TextWidthBasis.longestLine,
//       text: TextSpan(
//         style: style,
//         children: _getTextSpans().toList(),
//       ),
//     );
//   }
//
//   Iterable<TextSpan> _getTextSpans() sync* {
//     //
//     TextFormat textFormat = _textFormatter.formatText(text!);
//     var markerIndexes = textFormat.getMarkerIndexes();
//
//     if (markerIndexes.isEmpty) {
//       yield TextSpan(text: text);
//       return;
//     }
//
//     if (markerIndexes.first != 0) {
//       yield TextSpan(text: text!.substring(0, markerIndexes.first));
//     }
//
//     int startIndex = markerIndexes.first;
//     for (int endIndex in markerIndexes.skip(1)) {
//       //
//       var rangeStyle = textFormat.getStyle(startIndex);
//
//       if (startIndex + 1 < endIndex) {
//         yield TextSpan(
//           text: text!.substring(startIndex + 1, endIndex),
//           style: rangeStyle,
//         );
//       }
//
//       startIndex = endIndex;
//     }
//
//     if (markerIndexes.last != text!.length - 1) {
//       yield TextSpan(
//         text: text!.substring(markerIndexes.last + 1, text!.length),
//       );
//     }
//   }
//
//   /// Returns the text without formatting and without the formatting characters.
//   static Iterable<String> _plaintextSpans(String text) sync* {
//     //
//     var _textFormatter = WhatsAppTextFormatter();
//
//     TextFormat textFormat = _textFormatter.formatText(text);
//     var markerIndexes = textFormat.getMarkerIndexes();
//
//     if (markerIndexes.isEmpty) {
//       yield text;
//       return;
//     }
//
//     if (markerIndexes.first != 0) {
//       yield text.substring(0, markerIndexes.first);
//     }
//
//     int startIndex = markerIndexes.first;
//     for (int endIndex in markerIndexes.skip(1)) {
//       //
//       if (startIndex + 1 < endIndex) {
//         yield text.substring(startIndex + 1, endIndex);
//       }
//
//       startIndex = endIndex;
//     }
//
//     if (markerIndexes.last != text.length - 1) {
//       yield text.substring(markerIndexes.last + 1, text.length);
//     }
//   }
// }
//
// class WhatsAppTextFormatter extends TextFormatter {
//   //
//   WhatsAppTextFormatter({bool seUsaUnderline = false})
//       : super(
//           {
//             //
//             Marker.bold: _BoldRangeFormatter(),
//             //
//             Marker.italic: _ItalicRangeFormatter(),
//             //
//             Marker.strikeThrough: seUsaUnderline //
//                 ? _UnderlinedRangeFormatter()
//                 : _StrikeThroughRangeFormatter(),
//             //
//           },
//         );
//
//   @override
//   bool isValidStartMarker(String markerSymbol, int markerIndex, String text) {
//     //
//     if (text.length <= markerIndex + 2) {
//       return false;
//     }
//
//     var nextChar = text[markerIndex + 1];
//     var secondNextChar = text[markerIndex + 2];
//
//     if (_isEndDelimiter(nextChar)) {
//       return false;
//     }
//
//     if (nextChar == markerSymbol) {
//       //
//       if (_isMarkerSymbol(secondNextChar) || _isEndDelimiter(secondNextChar)) {
//         return false;
//       }
//     }
//
//     if (markerIndex != 0) {
//       //
//       var previousChar = text[markerIndex - 1];
//
//       if (!_isStartDelimiter(previousChar) && !_isAnotherMarkerSymbol(previousChar, markerSymbol))
//         return false;
//     }
//
//     return true;
//   }
//
//   @override
//   bool isValidEndMarker(String markerSymbol, int markerIndex, String text) {
//     //
//     if (markerIndex < 2) {
//       return false;
//     }
//
//     var previousChar = text[markerIndex - 1];
//     var secondPreviousChar = text[markerIndex - 2];
//
//     if (_isStartDelimiter(previousChar)) {
//       return false;
//     }
//
//     if (previousChar == markerSymbol && _isStartDelimiter(secondPreviousChar)) {
//       return false;
//     }
//
//     if (text.length > markerIndex + 1) {
//       //
//       var nextChar = text[markerIndex + 1];
//
//       if (!_isEndDelimiter(nextChar) && !_isMarkerSymbol(nextChar)) {
//         return false;
//       }
//     }
//
//     return true;
//   }
//
//   @override
//   void afterValidateEndMarker(int startMarkerIndex, int endMarkerIndex) {
//     resetAllStartMarkerIndexes(startIndex: startMarkerIndex);
//   }
//
//   static bool _isMarkerSymbol(String character) => Marker.values.contains(character);
//
//   static bool _isAnotherMarkerSymbol(String character, String markerSymbol) =>
//       Marker.values.where((value) => value != markerSymbol).contains(character);
//
//   static bool _isStartDelimiter(String char) {
//     return char == " " || char == "\n" || char == "\r" || char == "\u00A0";
//   }
//
//   static bool _isEndDelimiter(String char) {
//     return _endDelimiters.contains(char);
//   }
//
//   static final Set<String> _endDelimiters = {
//     " ",
//     "\n",
//     "\r",
//     "\u00A0",
//     ".",
//     ",",
//     ";",
//     "\\",
//     "/",
//     ":",
//     "?",
//     "[",
//     "]",
//     "(",
//     ")",
//     "{",
//     "}",
//     "\"",
//     "\'",
//     "!",
//     "@",
//     "#",
//     "\$",
//     "%",
//     "&",
//     "-",
//     "=",
//     "+",
//     "<",
//     ">",
//     "|",
//   };
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////
//
// class _BoldRangeFormatter extends RangeFormatter {
//   @override
//   TextStyle applyStyle(TextStyle style) => style.copyWith(fontWeight: FontWeight.bold);
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////
//
// class _ItalicRangeFormatter extends RangeFormatter {
//   @override
//   TextStyle applyStyle(TextStyle style) => style.copyWith(fontStyle: FontStyle.italic);
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////
//
// class _StrikeThroughRangeFormatter extends RangeFormatter {
//   @override
//   TextStyle applyStyle(TextStyle style) => style.copyWith(decoration: TextDecoration.lineThrough);
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////
//
// class _UnderlinedRangeFormatter extends RangeFormatter {
//   @override
//   TextStyle applyStyle(TextStyle style) => style.copyWith(decoration: TextDecoration.underline);
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////
//
// abstract class RangeFormatter {
//   //
//   int startMarkerIndex = -1;
//
//   TextStyle applyStyle(TextStyle style);
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////
//
// typedef StyleApplier = TextStyle Function(TextStyle);
//
// @immutable
// class TextFormat {
//   final String text;
//   final Map<Range, StyleApplier> _styleApplierByRange;
//
//   TextFormat(
//     this.text, {
//     required Map<Range, StyleApplier> styleApplierByRange,
//   }) : _styleApplierByRange = Map.unmodifiable(styleApplierByRange);
//
//   TextStyle getStyle(int index) {
//     var style = const TextStyle();
//
//     for (var pair in _styleApplierByRange.entries) {
//       if (pair.key.ini <= index && index < pair.key.fim) {
//         style = pair.value(style);
//       }
//     }
//
//     return style;
//   }
//
//   List<int> getMarkerIndexes() {
//     return _styleApplierByRange.keys
//         .expand(
//           (range) => [range.ini, range.fim],
//         )
//         .toList()
//       ..sort();
//   }
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////
//
// abstract class TextFormatter {
//   //
//   final Map<String, RangeFormatter> rangeFormatterBySymbol;
//
//   TextFormatter(this.rangeFormatterBySymbol);
//
//   TextFormat formatText(String text) {
//     //
//     resetAllStartMarkerIndexes();
//
//     var styleApplierByRange = <Range, StyleApplier>{};
//
//     for (int i = 0; i < text.length; i++) {
//       _processCharacter(styleApplierByRange, text[i], i, text);
//     }
//
//     return TextFormat(text, styleApplierByRange: styleApplierByRange);
//   }
//
//   void _processCharacter(
//       Map<Range, StyleApplier> styleApplierByRange, String character, int index, String text) {
//     //
//     if (!Marker.values.contains(character)) {
//       return;
//     }
//
//     var rangeFormatter = rangeFormatterBySymbol[character]!;
//
//     if (rangeFormatter.startMarkerIndex == -1) {
//       if (isValidStartMarker(character, index, text)) {
//         rangeFormatter.startMarkerIndex = index;
//       }
//     }
//     //
//     else if (isValidEndMarker(character, index, text)) {
//       styleApplierByRange[Range(rangeFormatter.startMarkerIndex, index)] =
//           rangeFormatter.applyStyle;
//       afterValidateEndMarker(rangeFormatter.startMarkerIndex, index);
//       rangeFormatter.startMarkerIndex = -1;
//     }
//   }
//
//   void resetAllStartMarkerIndexes({int startIndex = 0}) {
//     //
//     for (var manager in rangeFormatterBySymbol.values) {
//       if (startIndex <= manager.startMarkerIndex) {
//         manager.startMarkerIndex = -1;
//       }
//     }
//   }
//
//   bool isValidStartMarker(String markerSymbol, int markerIndex, String text);
//
//   bool isValidEndMarker(String markerSymbol, int markerIndex, String text);
//
//   void afterValidateEndMarker(int startMarkerIndex, int endMarkerIndex) {}
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////
//
// class Marker {
//   //
//   static const bold = '*';
//   static const italic = '_';
//   static const strikeThrough = '~';
//
//   static const values = <String>[
//     bold,
//     italic,
//     strikeThrough,
//   ];
// }
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////
