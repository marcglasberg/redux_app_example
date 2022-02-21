import 'package:async_redux_project_template/_EXPORT.dart';
import "package:flutter/material.dart";

/// A span of time in hours and minutes only.
@immutable
class HourMinSeg implements Comparable<HourMinSeg> {
  //
  static const HourMinSeg zero = const HourMinSeg(h: 0, min: 0, seg: 0);

  /// Duration in seconds.
  final int duration;

  const HourMinSeg({
    required int h,
    required int min,
    required int seg,
  }) : this._seconds(Duration.secondsPerHour * h + Duration.secondsPerMinute * min + seg);

  HourMinSeg.from(Duration duration) : this._seconds(duration.inSeconds);

  Duration toDuration() => Duration(seconds: duration);

  /// Truncate to 24 hour (the result will always be between 0 and 24 hours).
  ///
  /// Examples:
  ///
  /// - 14:30 will become 14:30.
  /// - 24:00 will become 0:00.
  /// - 26:10 or will become 2:10.
  /// - Note negative will become positive. So -1:00 will become 23:00.
  ///
  HourMinSeg truncateTo24Hour() {
    var remainder = duration.remainder(Duration.secondsPerDay);
    if (remainder < 0) remainder += Duration.secondsPerDay;

    return HourMinSeg._seconds(remainder);
  }

  AmPm getAmPm() {
    if (truncateTo24Hour().h < 12)
      return AmPm.am;
    else
      return AmPm.pm;
  }

  // Fast path internal direct constructor to avoid the optional arguments and seconds computation.
  const HourMinSeg._seconds(this.duration);

  HourMinSeg operator +(HourMinSeg other) => HourMinSeg._seconds(duration + other.duration);

  HourMinSeg operator -(HourMinSeg other) => HourMinSeg._seconds(duration - other.duration);

  ///  Multiplies this HourMinSeg by the given factor.
  HourMinSeg operator *(int factor) => HourMinSeg._seconds(duration * factor);

  /// Divides this HourMinSeg by the given quotient and returns the truncated result.
  /// Throws an [UnsupportedError] if quotient is `0`.
  HourMinSeg operator ~/(int quotient) {
    // By doing the check here instead of relying on "~/" below we get the
    // exception even with dart2js.
    if (quotient == 0) throw UnsupportedError('Division by zero');
    return HourMinSeg._seconds(duration ~/ quotient);
  }

  bool operator <(HourMinSeg other) => duration < other.duration;

  bool operator >(HourMinSeg other) => duration > other.duration;

  bool operator <=(HourMinSeg other) => duration <= other.duration;

  bool operator >=(HourMinSeg other) => duration >= other.duration;

  /// Returns the number of whole minutes.
  /// The returned value can be greater than 59.
  int get totalMinutes => duration ~/ 60;

  /// Returns the number of whole seconds.
  /// The returned value can be greater than 59.
  int get totalSeconds => duration;

  /// Returns the number of whole hours.
  /// The returned value can be greater than 23.
  int get h => duration ~/ Duration.secondsPerHour;

  /// Returns the number of minutes not counting whole hours.
  /// The returned value is always between 0 and 59.
  int get min => (duration ~/ 60).remainder(Duration.secondsPerMinute);

  /// Returns the number of minutes not counting whole hours.
  /// The returned value is always between 0 and 59.
  int get seg => duration.remainder(Duration.secondsPerMinute);

  /// Important: Always 24-hour format.
  /// Returns the simple hour and minute, in the format "hh:mm" or "h:mm".
  /// Note: hour may have 1 or 2 digits. But minutes is always 2.
  /// If the time is negative, it will have a "-" before it, for example: "-5:32".
  String formatSimple() {
    var hourStr = h.toString();

    var minStr = (min.abs()).toString();
    if (minStr.length == 1) minStr = "0" + minStr;

    var segStr = (seg.abs()).toString();
    if (segStr.length == 1) segStr = "0" + segStr;

    return hourStr + ":" + minStr + ":" + segStr;
  }

  bool get isZero => duration == 0;

  /// Returns whether this `HourMinSeg` is negative.
  /// A negative `HourMinSeg` represents the difference from a later time to an earlier time.
  bool get isNegative => duration < 0;

  HourMinSeg abs() => HourMinSeg._seconds(duration.abs());

  /// Negated.
  HourMinSeg operator -() => new HourMinSeg._seconds(0 - duration);

  String formatAudioDuration() {
    //
    StringBuffer durationStr = StringBuffer();

    var h = this.h;

    if (h > 0) {
      durationStr.write(h);
      durationStr.write(":");
    }

    var minutes = min.remainder(Duration.minutesPerHour);
    var minutesString = minutes.toString();
    durationStr.write(h > 0 ? minutesString.padLeft(2, "0") : minutesString);
    durationStr.write(":");

    var seconds = seg.remainder(Duration.secondsPerMinute);
    durationStr.write(seconds.toString().padLeft(2, "0"));

    return durationStr.toString();
  }

  @override
  String toString() => "${h}h:${min}min:${seg}s";

  @override
  int compareTo(HourMinSeg other) => duration.compareTo(other.duration);

  @override
  bool operator ==(Object other) => (other is HourMinSeg) ? duration == other.duration : false;

  @override
  int get hashCode => duration.hashCode;
}
