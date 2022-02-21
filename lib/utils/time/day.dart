import 'package:async_redux_project_template/_EXPORT.dart';
import "package:clock/clock.dart";
import "package:intl/intl.dart";
import "package:meta/meta.dart";

////////////////////////////////////////////////////////////////////////////////////////////////////

enum IntervalType { day, week, month, year }

////////////////////////////////////////////////////////////////////////////////////////////////////

abstract class TemDay {
  Day get day;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class DayRange {
  final Day ini, end;

  const DayRange(this.ini, this.end) : assert(ini <= end);

  /// Returns the number of days in the range, inclusive.
  /// If [ini] == [end] returns 1.
  ///
  int get daysInRange => end - ini + 1;

  @override
  String toString() => '($ini, $end)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayRange && runtimeType == other.runtimeType && ini == other.ini && end == other.end;

  @override
  int get hashCode => ini.hashCode ^ end.hashCode;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

/// The day, without time, and without timezone information.
@immutable
class Day implements Comparable<Day>, TemDay {
  //
  /// Limits Day e DayTime between years 1 e 9999 (compatible with Firestore's Timestamp class)
  /// Note: Day and DayTime are based on Dart's DateTime, which has microsecond precision (10 ^ 6)
  /// and a very wide range. However, any date saved in the Firestore uses Timestamp, which has a
  /// smaller range and greater precision (10 ^ 9 nanoseconds). I then decided to keep Dart
  /// accurate, but within the Timestamp range. This prevents wrong dates from being read / saved
  /// in the Firestore. Anyway, to avoid attacks, it is up to the interface and the backend to
  /// avoid absurd years, which can cause problems. It is suggested that both the interface and the
  /// backend limit dates between the years 1950 and 2100.
  static const int minYear = 1;
  static const int maxYear = 9999;

  // In practice, we try to limit the UI and backend to years 1900 and 2100:
  static const int safeMinYear = 1900;
  static const int safeMaxYear = 2100;

  // Weekday constants that are returned by [weekday] method:
  static const int monday = 1;
  static const int tuesday = 2;
  static const int wednesday = 3;
  static const int thursday = 4;
  static const int friday = 5;
  static const int saturday = 6;
  static const int sunday = 7;
  static const int daysPerWeek = 7;

  // Month constants that are returned by the [month] getter.
  static const int january = 1;
  static const int february = 2;
  static const int march = 3;
  static const int april = 4;
  static const int may = 5;
  static const int june = 6;
  static const int july = 7;
  static const int august = 8;
  static const int september = 9;
  static const int october = 10;
  static const int november = 11;
  static const int december = 12;
  static const int monthsPerYear = 12;

  // Minimum date (in the past).
  static final Day minDay = Day(minYear, 1, 1);

  // Maximum date (in the future).
  static final Day maxDay = Day(maxYear, 12, 31);

  // In practice, we try to limit the UI and backend to years 1900 and 2100:
  static final Day safeMinDay = DayTime.safeMinDayTime.day;
  static final Day safeMaxDay = DayTime.safeMaxDayTime.day;

  final DateTime dateOnlyUtc;

  @override
  Day get day => this;

  int get yearInt => dateOnlyUtc.year;

  int get monthInt => dateOnlyUtc.month;

  int get dayInt => dateOnlyUtc.day;

  /// Returns the month, with 2 chars: "01" ... "12".
  String get month2digits {
    int mes = monthInt;
    return (mes >= 10) ? mes.toString() : "0$mes";
  }

  /// Returns the day, with 2 chars: "01" ... "12".
  String get day2digits {
    int dia = dayInt;
    return (dia >= 10) ? dia.toString() : "0$dia";
  }

  /// A week starts on Monday, which has value 1.
  int get weekday => dateOnlyUtc.weekday;

  DayOfWeek get dayOfWeek => DayOfWeek.fromDay(this);

  Day(
    int year, [
    int month = 1,
    int day = 1,
  ]) : dateOnlyUtc = DateTime.utc(year, month, day) {
    checkValidYear(dateOnlyUtc.year);
  }

  /// Get the current day, according to local time.
  static Day todayInTheLocalTimezone() {
    var now = clock.now();
    return now.isUtc ? Day.from(now.toLocal()) : Day.from(now);
  }

  /// Get the current day, according to UTC.
  static Day todayUtc() {
    var now = clock.now();
    return now.isUtc ? Day.from(now) : Day.from(now.toUtc());
  }

  /// AVOID USING.
  /// Constructor that discards UTC information (does not convert to UTC).
  /// This will change the timezone if dateTime is not in UTC.
  Day.from(DateTime dateTime) : dateOnlyUtc = _dateOnlyUtc(dateTime) {
    checkValidYear(dateOnlyUtc.year);
  }

  static DateTime _dateOnlyUtc(DateTime dateTime) {
    return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
  }

  static void checkValidYear(int year) {
    if (year < minYear || (year > maxYear))
      throw AssertionError("Invalid: year $year (valid between $minYear and $maxYear).");
  }

  /// Example: var day = Day.parse("2019-06-14 20:42:02.314Z");
  /// It also works if instead of space as a separator it's 'T': "2019-06-14T20:42:02.314Z".
  /// To avoid errors, note  the date must end in 'Z', otherwise throws exception.
  static Day parse(String formattedString) {
    var dayTime = DayTime.parse(formattedString);
    return dayTime.day;
  }

  DayTime withHourMin(HourMin hourMin) =>
      DayTime(yearInt, monthInt, dayInt, hourMin.h, hourMin.min);

  /// First millisecond of the day.
  DayTime toDayTime() => DayTime.from(dateOnlyUtc);

  /// Last millisecond of the day.
  DayTime toEndOfDayTime() => nextDay().toDayTime().subtract(const Duration(milliseconds: 1));

  DayTime withTime({int hour = 0, int minute = 0, int second = 0, int millisecond = 0}) =>
      DayTime(yearInt, monthInt, dayInt, hour, minute, second, millisecond);

  /// If the month number exists in all months, returns true if the number of month is the same.
  /// For example, (15 Aug).ifIsExactMonthsFrom(15 Feb) == true.
  ///
  /// If the month number does not exist in the month, returns true on the first day of the next
  /// month. For example, (30 Set).ifIsExactMonthsTo(1 Mar) == true, since 30 Feb doesn't exist.
  bool ifIsExactMonthsTo(Day day) {
    //
    // 1) If the day of the month is the same, it's an exact month away.
    if (dayInt == day.dayInt)
      return true;

    // If the date is not the first, it cannot be a few months away from the end of some month.
    else if (day.dayInt != 1)
      return false;

    // If the date is the first, it is a few months away if the day before has a day of month number before today.
    else
      return (day.prevDay().dayInt < dayInt);
  }

  @useResult
  Day prevWeek() => subtractDays(7);

  @useResult
  Day nextWeek() => addDays(7);

  @useResult
  Day prevDay() => subtractDays(1);

  @useResult
  Day nextDay() => addDays(1);

  /// Returns true is the current day is workday (not holiday and not saturday/sunday).
  bool isWorkday(Set<Day>? holidays) {
    return (weekday != DateTime.saturday) &&
        (weekday != DateTime.sunday) &&
        (holidays == null || !holidays.contains(day));
  }

  /// Returns true is the current day is NOT a workday (is a holiday or saturday/sunday).
  bool isNotWorkday(Set<Day>? holidays) {
    return (weekday == DateTime.saturday) ||
        (weekday == DateTime.sunday) ||
        (holidays != null && holidays.contains(day));
  }

  /// Returns the next workday.
  @useResult
  Day nextWorkday(Set<Day>? holidays) {
    holidays ??= const {};

    Day day = this;
    int weekday;

    do {
      day = day.nextDay();
      weekday = day.weekday;
    } while (holidays.contains(day) //
        ||
        (weekday == DateTime.saturday) ||
        (weekday == DateTime.sunday));

    return day;
  }

  /// Returns the previous workday.
  @useResult
  Day prevWorkday(Set<Day>? holidays) {
    holidays ??= const {};

    Day day = this;
    int weekday;

    do {
      day = day.prevDay();
      weekday = day.weekday;
    } while (holidays.contains(day) //
        ||
        (weekday == DateTime.saturday) ||
        (weekday == DateTime.sunday));

    return day;
  }

  /// If today is a workday, return today.
  /// Otherwise, returns the next workday.
  @useResult
  Day todayOrNextWorkday(Set<Day>? holidays) {
    //
    int weekday = this.weekday;

    return (holidays == null || !holidays.contains(this)) //
            &&
            (weekday != DateTime.saturday) &&
            (weekday != DateTime.sunday)
        ? this
        : nextWorkday(holidays);
  }

  /// If today is a workday, return today.
  /// Otherwise, returns the previous workday.
  @useResult
  Day todayOrPrevWorkday(Set<Day>? holidays) {
    int weekday = this.weekday;

    return (holidays == null || !holidays.contains(this)) //
            &&
            (weekday != DateTime.saturday) &&
            (weekday != DateTime.sunday)
        ? this
        : prevWorkday(holidays);
  }

  static bool isSameWeek(Day day1, Day day2) {
    var diff = day1.difference(day2).inDays;
    if (diff.abs() >= 7) return false;

    var min = day1.isBefore(day2) ? day1 : day2;
    var max = day1.isBefore(day2) ? day2 : day1;
    return max.weekday % 7 - min.weekday % 7 >= 0;
  }

  /// Return a day for each day the given range.
  /// If end is AFTER or EQUAL to start, goes from start to end, inclusive.
  /// If end is BEFORE start, goes from start-exclusive to end-inclusive (goes back in time).
  static Iterable<Day> daysInRange(Day start, Day end) sync* {
    if (end.isAfterOrEqual(start))
      while (end.isAfterOrEqual(start)) {
        yield start;
        start = start.nextDay();
      }
    else
      while (end.isBefore(start)) {
        start = start.prevDay();
        yield start;
      }
  }

  /// Returns a day for each day the given range. Start and end inclusive.
  static Iterable<Day> daysInMonth(int year, int month) {
    Day firstDayOfMonth = Day(year, month, 1);
    Day lastDayOfMonth = firstDayOfMonth.lastDayOfMonth();
    return daysInRange(firstDayOfMonth, lastDayOfMonth);
  }

  /// Returns a list of formatted week days, starting Monday.
  static List<String> weekDays(String localeName) {
    DateFormat formatter = DateFormat(DateFormat.WEEKDAY, localeName);
    return [
      DateTime(2000, 1, 3, 1),
      DateTime(2000, 1, 4, 1),
      DateTime(2000, 1, 5, 1),
      DateTime(2000, 1, 6, 1),
      DateTime(2000, 1, 7, 1),
      DateTime(2000, 1, 8, 1),
      DateTime(2000, 1, 9, 1),
    ].map((day) => formatter.format(day)).toList();
  }

  static int numberOfLastDayOfMonth(int year, int month) =>
      Day(year, month).lastDayOfMonth().dayInt;

  static Day max(Day day1, Day day2) => day1.isAfter(day2) ? day1 : day2;

  static Day min(Day day1, Day day2) => day1.isBefore(day2) ? day1 : day2;

  @useResult
  Day lastDayOfMonth() {
    var firstDayOfNextMonth =
        (monthInt < 12) ? Day(yearInt, monthInt + 1, 1) : Day(yearInt + 1, 1, 1);
    return firstDayOfNextMonth.prevDay();
  }

  @useResult
  Day firstDayOfMonth() {
    return Day(yearInt, monthInt, 1);
  }

  @useResult
  Day add(Duration duration) => Day.from(dateOnlyUtc.add(duration));

  @useResult
  Day addDays(int numberOfDays) => Day(yearInt, monthInt, dayInt + numberOfDays);

  @useResult
  Day subtractDays(int numberOfDays) => Day(yearInt, monthInt, dayInt - numberOfDays);

  @useResult
  Day addWeeks(int numberOfWeeks) => addDays(numberOfWeeks * 7);

  @useResult
  Day addMonths(int numberOfMonths) => Day(yearInt, monthInt + numberOfMonths, dayInt);

  @useResult
  Day addYears(int numberOfYears) => Day(yearInt + numberOfYears, monthInt, dayInt);

  @useResult
  Day subtract(Duration duration) => Day.from(dateOnlyUtc.subtract(duration));

  /// Number of days between two dates.
  /// Takes into account daylight savings.
  /// Is zero for the same day.
  /// Positive, if [day] is AFTER the current day.
  /// Negative if [day] is BEFORE the current day.
  int daysUntil(Day day) => (day.difference(this).inHours / 24).round();

  static int daysBetween({required Day from, required Day to}) => from.daysUntil(to);

  Duration difference(Day day) => dateOnlyUtc.difference(day.dateOnlyUtc);

  bool isAfter(Day day) => dateOnlyUtc.isAfter(day.dateOnlyUtc);

  bool isBefore(Day day) => dateOnlyUtc.isBefore(day.dateOnlyUtc);

  bool isAfterOrEqual(Day day) => !dateOnlyUtc.isBefore(day.dateOnlyUtc);

  bool isBeforeOrEqual(Day day) => !dateOnlyUtc.isAfter(day.dateOnlyUtc);

  bool isBetweenIncluding(Day dayIni, Day dayEnd) =>
      isAfterOrEqual(dayIni) && isBeforeOrEqual(dayEnd);

  bool isBetweenExcluding(Day dayIni, Day dayEnd) => isAfter(dayIni) && isBefore(dayEnd);

  bool ifItsInThePast_InTheLocalTimezone() => Day.todayInTheLocalTimezone().isAfter(this);

  String formatWith(DateFormat formatter) => formatter.format(dateOnlyUtc);

  int get millisecondsSinceEpoch => dateOnlyUtc.millisecondsSinceEpoch;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Day && runtimeType == other.runtimeType && dateOnlyUtc == other.dateOnlyUtc;

  bool operator >(Day other) => isAfter(other);

  bool operator >=(Day other) => isAfterOrEqual(other);

  bool operator <(Day other) => isBefore(other);

  bool operator <=(Day other) => isBeforeOrEqual(other);

  int operator -(Day other) => daysBetween(from: other, to: this);

  @override
  int get hashCode => dateOnlyUtc.hashCode;

  @override
  int compareTo(Day other) => dateOnlyUtc.compareTo(other.dateOnlyUtc);

  // Something like: 2020-11-05
  @override
  String toString() => "${yearInt.toString()}-$month2digits-$day2digits";

  /// Not very efficient, because it calculates by looping.
  static int calculateNumberOfIntervals(Day? start, Day? end, IntervalType type) {
    //
    if (start == null || end == null || end.isBefore(start))
      return 0;
    else {
      int numberOfIntervals = 0;
      Day current = start;
      do {
        if (type == IntervalType.day)
          current = current.addDays(1);
        else if (type == IntervalType.week)
          current = current.addWeeks(1);
        else if (type == IntervalType.month)
          current = current.addMonths(1);
        else if (type == IntervalType.year)
          current = current.addYears(1);
        else
          throw AssertionError(type);

        if (current.isBeforeOrEqual(end)) numberOfIntervals++;
      } while (current.isBefore(end));

      return numberOfIntervals;
    }
  }

  @useResult
  Day addInterval(int numberOfIntervals, IntervalType type) {
    if (numberOfIntervals < 0)
      return this;
    else if (type == IntervalType.day)
      return addDays(numberOfIntervals);
    else if (type == IntervalType.week)
      return addWeeks(numberOfIntervals);
    else if (type == IntervalType.month)
      return addMonths(numberOfIntervals);
    else if (type == IntervalType.year)
      return addYears(numberOfIntervals);
    else
      throw AssertionError(type);
  }
}
