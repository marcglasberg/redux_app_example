import 'package:async_redux_project_template/_EXPORT.dart';
import "package:flutter/material.dart";



abstract class WithTime {
  HourMin get hourMin;
}



class HourMinRange {
  final HourMin ini, end;

  const HourMinRange(this.ini, this.end);

  /// The number of minutes between ini and end. Is zero if both are equal.
  int get inMinutes => (end.totalMinutes - ini.totalMinutes).abs();

  @override
  String toString() => '($ini, $end)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HourMinRange &&
          runtimeType == other.runtimeType &&
          ini == other.ini &&
          end == other.end;

  @override
  int get hashCode => ini.hashCode ^ end.hashCode;
}



/// A span of time in hours and minutes only.
@immutable
class HourMin implements Comparable<HourMin> {
  //
  static const zero = HourMin(h: 0, min: 0);

  /// The number of whole minutes. Can be greater than 59.
  final int totalMinutes;

  const HourMin({
    required int h,
    required int min,
  }) : this._minutes(Duration.minutesPerHour * h + min);

  HourMin.from(Duration duration) : this._minutes(duration.inMinutes);

  Duration toDuration() => Duration(minutes: totalMinutes);

  /// Truncate to 24 hour (the result will always be between 0 and 24 hours).
  /// Examples:
  /// - 14:30 will become 14:30.
  /// - 24:00 will become 0:00.
  /// - 26:10 or will become 2:10.
  /// - Note negative will become positive. So -1:00 will become 23:00.
  HourMin truncateTo24Hour() {
    var remainder = totalMinutes.remainder(Duration.minutesPerDay);
    if (remainder < 0) remainder += Duration.minutesPerDay;

    return HourMin._minutes(remainder);
  }

  AmPm getAmPm() => (truncateTo24Hour().h < 12) ? AmPm.am : AmPm.pm;

  // Fast path internal direct constructor to avoids the optional arguments and minutes recomputation.
  const HourMin._minutes(this.totalMinutes);

  HourMin operator +(HourMin other) {
    return HourMin._minutes(totalMinutes + other.totalMinutes);
  }

  HourMin operator -(HourMin other) {
    return HourMin._minutes(totalMinutes - other.totalMinutes);
  }

  ///  Multiplies this ShortDuration by the given factor.
  HourMin operator *(int factor) {
    return HourMin._minutes(totalMinutes * factor);
  }

  /// Divides this ShortDuration by the given quotient and returns the truncated result.
  /// Throws an [UnsupportedError] if quotient is `0`.
  HourMin operator ~/(int quotient) {
    // By doing the check here instead of relying on "~/" below we get the
    // exception even with dart2js.
    if (quotient == 0) throw UnsupportedError('Division by zero');
    return HourMin._minutes(totalMinutes ~/ quotient);
  }

  bool operator <(HourMin other) => totalMinutes < other.totalMinutes;

  bool operator >(HourMin other) => totalMinutes > other.totalMinutes;

  bool operator <=(HourMin other) => totalMinutes <= other.totalMinutes;

  bool operator >=(HourMin other) => totalMinutes >= other.totalMinutes;

  /// Returns the number of whole hours.
  /// The returned value can be greater than 23.
  int get h => totalMinutes ~/ Duration.minutesPerHour;

  /// Returns the number of minutes not counting whole hours.
  /// The returned value is always between 0 and 59.
  int get min => totalMinutes.remainder(Duration.minutesPerHour);

  /// Important: Always 24-hour format.
  /// Returns the simple hour and minute, in the format "hh:mm" or "h:mm" or " h:mm".
  /// Note: hour may have 1 or 2 digits. But minutes is always 2.
  /// If the time is negative, it will have a "-" before it, for example: "-5:32".
  String formatSimple({bool seHoraTemEspaco = false}) {
    var hourStr = h.toString();
    if (hourStr.length == 1 && seHoraTemEspaco) hourStr = space + hourStr;
    var minStr = (min.abs()).toString();
    if (minStr.length == 1) minStr = "0" + minStr;

    return "$hourStr:$minStr";
  }

  // Same as [formatSimple], but in round times return something like "8hs" instead of "8:00".
  String formatSimpleWithLetter() => (min == 0) ? "${h}hs" : formatSimple();

  bool get isZero => totalMinutes == 0;

  /// Returns whether this `ShortDuration` is negative.
  /// A negative `ShortDuration` represents the difference from a later time to an earlier time.
  bool get isNegative => totalMinutes < 0;

  HourMin abs() => HourMin._minutes(totalMinutes.abs());

  /// Negated.
  HourMin operator -() => new HourMin._minutes(0 - totalMinutes);

  @override
  String toString() => "${h}h:${min}min";

  @override
  int compareTo(HourMin other) => totalMinutes.compareTo(other.totalMinutes);

  @override
  bool operator ==(Object other) {
    if (other is HourMin)
      return totalMinutes == other.totalMinutes;
    else
      return false;
  }

  @override
  int get hashCode => totalMinutes.hashCode;
}



/// This class is equivalent to Day and DayTime.
/// 1) Equivalent to Day, if hourMin is null.
/// 2) Equivalent to DayTime, if hourMin is NOT null.
@immutable
class DayHourMin implements Comparable<DayHourMin> {
  //
  final Day day;
  final HourMin hourMin;

  DayHourMin(this.day, this.hourMin);

  DayHourMin.fromDay(this.day) : hourMin = HourMin.zero;

  DayHourMin.fromDayTime(DayTime dayTime)
      : day = dayTime.day,
        hourMin = dayTime.toHourMin();

  @override
  int compareTo(DayHourMin other) {
    int result = day.compareTo(other.day);
    if (result != 0)
      return result;
    else
      return hourMin.compareTo(other.hourMin);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayHourMin &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          hourMin == other.hourMin;

  @override
  int get hashCode => day.hashCode ^ hourMin.hashCode;

  DayTime toDayTime() => day.withHourMin(hourMin);

  @override
  String toString() => toDayTime().toString();

  /// Returns the number of whole hours.
  /// The returned value can be greater than 23.
  int get h => hourMin.h;

  /// Returns the number of minutes not counting whole hours.
  /// The returned value is always between 0 and 59.
  int get min => hourMin.min;
}


