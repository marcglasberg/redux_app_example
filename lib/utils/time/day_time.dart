import 'package:async_redux_project_template/_EXPORT.dart';
import "package:clock/clock.dart";
import "package:intl/intl.dart";
import "package:meta/meta.dart";
import 'package:timezone/timezone.dart';



enum AmPm { am, pm }



class DayTimeRange {
  final DayTime ini, end;

  const DayTimeRange(this.ini, this.end);

  factory DayTimeRange.from(Day day, HourMinRange range) =>
      DayTimeRange(day.withHourMin(range.ini), day.withHourMin(range.end));

  /// Returns the duration between [ini] and [end]
  /// If [ini] == [end] returns 0.
  ///
  Duration get duration => end - ini;

  /// Return true if [dayTime] is in the range (inclusive).
  bool isInRange(DayTime dayTime) => ini.isBeforeOrEqual(dayTime) && end.isAfterOrEqual(dayTime);

  DayTimeRange extendBy({required Duration before, required Duration after}) =>
      DayTimeRange(ini.subtract(before), end.add(after));

  /// Divides the present range into [number] ranges.
  List<DayTimeRange> dividedBy(int number) {
    //
    Duration dividedDuration = duration ~/ number;

    // Start at [ini], and add dividedDuration.
    List<DayTimeRange> list = [];
    DayTime dayTime = ini;
    for (int i = 0; i < number - 1; i++) {
      var nextDayTime = dayTime + dividedDuration;
      list.add(DayTimeRange(dayTime, nextDayTime));
      dayTime = nextDayTime;
    }

    // The last one uses [end] to avoid rounding errors when adding the dividedDuration;
    list.add(DayTimeRange(dayTime, end));

    return list;
  }

  /// Returns the range, limited to the given [day].
  DayTimeRange limitTo(Day day) {
    //
    var ini = this.ini;
    var end = this.end;

    var dayTimeIni = day.toDayTime();
    var dayTimeEnd = day.toEndOfDayTime();

    if (ini > dayTimeEnd) ini = dayTimeEnd;
    if (ini < dayTimeIni) ini = dayTimeIni;

    if (end > dayTimeEnd) end = dayTimeEnd;
    if (end < dayTimeIni) end = dayTimeIni;

    return ((ini == this.ini) && (end == this.end)) //
        ? this
        : DayTimeRange(ini, end);
  }

  @override
  String toString() => '($ini, $end)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayTimeRange &&
          runtimeType == other.runtimeType &&
          ini == other.ini &&
          end == other.end;

  @override
  int get hashCode => ini.hashCode ^ end.hashCode;
}



/// The day, with time, without timezone.
///
/// 1) DayTime does NOT have a timezone, unlike Dart's DateTime (note DateTime only says if the
/// timezone is local or UTC, but does not define the local timezone). Internally, DayTime is
/// represented by a DateTime in UTC, but this is irrelevant.
///
/// 2) The DayTime range is the same as the Firestore's Timestamp: between the years 1 and 9999.
/// Note that this range is much smaller than the Dart's DateTime range.
///
/// 3) The accuracy of DayTime is the same as that of JavaScript Date: milliseconds. Note that this
/// range is a thousand times smaller than the Dart's DateTime range, and 1 million times smaller
/// than the Firestore's Timestamp rank. Note: DayTime is the lowest common denominator between
/// DateTime (Dart), Date (JavaScript) and Timestamp (Firestore). That is, it can be converted
/// correctly to any of these three, but it will lose accuracy and range when converted back.
///
@immutable
class DayTime implements Comparable<DayTime>, TemDay {
  //
  static bool get ifIs12HourFormat => Localization_DayTime.ifIs12HourFormat;

  /// Limits Day e DayTime between years 1 e 9999 (compatible with Firestore's Timestamp class)
  /// Note: Day and DayTime are based on Dart's DateTime, which has microsecond precision (10 ^ 6)
  /// and a very wide range. However, any date saved in the Firestore uses Timestamp, which has a
  /// smaller range and greater precision (10 ^ 9 nanoseconds). I then decided to keep Dart
  /// accurate, but within the Timestamp range. This prevents wrong dates from being read / saved
  /// in the Firestore. Anyway, to avoid attacks, it is up to the interface and the backend to
  /// avoid absurd years, which can cause problems. It is suggested that both the interface and the
  /// backend limit dates between the years 1950 and 2100.
  static const int minYear = Day.minYear;
  static const int maxYear = Day.maxYear;

  // Minimum date (in the past).
  static final DayTime minDayTime = DayTime(minYear, 1, 1, 0, 0, 0, 0);

  // Maximum date (in the future).
  static final DayTime maxDayTime = DayTime(maxYear, 12, 31, 23, 59, 59, 999);

  /// May be between or equal to these:
  static const int minMillisecondsFromEpoch = -62135596800000;
  static const int maxMillisecondsFromEpoch = 253402300799999;

  // In practice, we try to limit the UI and backend to years 1900 and 2100:
  static const int safeMinYear = Day.safeMinYear;
  static const int safeMaxYear = Day.safeMaxYear;
  static final DayTime safeMinDayTime = DayTime(safeMinYear, 1, 1, 0, 0, 0, 0);
  static final DayTime safeMaxDayTime = DayTime(safeMaxYear, 12, 31, 23, 59, 59, 999);
  static const int safeMinMillisecondsFromEpoch = -2208988800000;
  static const int safeMaxMillisecondsFromEpoch = 4133980799999;

  /// In UTC, with millisecond precision.
  final DateTime dateTimeUtc;

  int get anoInt => dateTimeUtc.year;

  int get mesInt => dateTimeUtc.month;

  int get diaInt => dateTimeUtc.day;

  int get horaInt => dateTimeUtc.hour;

  int get minInt => dateTimeUtc.minute;

  int get segInt => dateTimeUtc.second;

  int get millis => dateTimeUtc.millisecond;

  /// Year must be between minYear and maxYear.
  /// Month must be must be between 1 (Jan) e 12 (Dec).
  /// Day must be between 1 and 31.
  /// Hour must be between 0 and 23.
  /// Minute and second must be between 0 and 59.
  /// Millisecond must be between 0 e 999.
  DayTime(
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
  ]) : dateTimeUtc = DateTime.utc(year, month, day, hour, minute, second, millisecond, 0) {
    //
    Day.checkValidYear(dateTimeUtc.year);

    if (hour < 0 || hour > 23)
      throw AssertionError("Hour: $hour (valid 0 to 23).");
    else if (minute < 0 || minute > 59)
      throw AssertionError("Minute:  $minute (valid 0 to 59).");
    else if (second < 0 || second > 59)
      throw AssertionError("Second: $second (valid 0 to 59).");
    else if (millisecond < 0 || millisecond > 999)
      throw AssertionError("Millisecond: $second (valid 0 to 999).");
  }

  /// AVOID USING.
  /// Constructor that discards UTC information (does not convert to UTC).
  /// This will change the timezone if dateTime is not in UTC.
  DayTime.from(DateTime dateTime) : dateTimeUtc = _utc(dateTime) {
    Day.checkValidYear(dateTimeUtc.year);
  }

  /// This is the correct way to keep time taking into account the timezone.
  DayTime.convertToUtc(DateTime dateTime) : dateTimeUtc = _utc(dateTime.toUtc()) {
    Day.checkValidYear(dateTimeUtc.year);
  }

  DayTime.fromMillisecondsFromEpoch(int millis)
      : dateTimeUtc = DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true) {
    Day.checkValidYear(dateTimeUtc.year);
  }

  DayTime.fromDay(Day day, [int hour = 0, int minute = 0, int second = 0, int millisecond = 0])
      : dateTimeUtc =
            DateTime.utc(day.yearInt, day.monthInt, day.dayInt, hour, minute, second, millisecond) {
    Day.checkValidYear(dateTimeUtc.year);
  }

  DayOfWeek get dayOfWeek => DayOfWeek.fromDayTime(this);

  String print() => formatTime(ifRemoveSpace: true);

  /// Return the [TZDateTime] of the dateTimeUtc in the local timezone.
  /// As described in the class documentation, day-times do not have timezone information, despite
  /// the name of the dateTimeUtc variable. To make up for the lack of this information, this method
  /// returns a TZDateTime in which the dateTimeUtc was assigned to the local timezone.
  /// Note that this method depends on the location defined by the setLocalLocation () function.
  /// If location has not been defined, it throws an error.
  ///
  TZDateTime toTZDateTime() {
    return TZDateTime.local(
      dateTimeUtc.year,
      dateTimeUtc.month,
      dateTimeUtc.day,
      dateTimeUtc.hour,
      dateTimeUtc.minute,
      dateTimeUtc.second,
      dateTimeUtc.millisecond,
    );
  }

  static String? join(
    List<DayTime> times, {
    String? amPmSeparator,
  }) {
    if (times.isEmpty)
      return null;
    //
    else if (times.length == 1)
      return times[0].formatTime(ifRemoveSpace: true, amPmSeparator: amPmSeparator);
    //
    else
      return times
          .map((h) => h.formatTime(ifRemoveSpace: true, amPmSeparator: amPmSeparator))
          .join(", ");
  }

  int get millisecondsSinceEpoch => dateTimeUtc.millisecondsSinceEpoch;

  /// Converts a DayTime list into a DateTime list.
  static List<DateTime> convertsDayTimeListIntoDateTimeList(List<DayTime> dayTimes) =>
      dayTimes.map((dayTime) => dayTime.dateTimeUtc).toList();

  @useResult
  DayTime withHourMin(HourMin hourMin) => DayTime(anoInt, mesInt, diaInt, hourMin.h, hourMin.min);

  @useResult
  DayTime withHourMinSec(int hour, int minute, int second) =>
      DayTime(anoInt, mesInt, diaInt, hour, minute, second);

  @useResult
  DayTime addHourMin(HourMin hourMin) => add(hourMin.toDuration());

  AmPm getAmPm() => (horaInt < 12) ? AmPm.am : AmPm.pm;

  /// Get the current day-time, according to local time.
  static DayTime nowInTheLocalTimezone() {
    var now = clock.now();
    return now.isUtc ? DayTime.from(now.toLocal()) : DayTime.from(now);
  }

  /// Get the current day, according to UTC.
  static DayTime nowUtc() {
    var now = clock.now();
    return now.isUtc ? DayTime.from(now) : DayTime.from(now.toUtc());
  }

  /// This method assumes DayTime represents a time in the UTC timezone, and then converts it to a
  /// DayTime that represents a time in the local timezone.
  ///
  /// Example 1: The timestamp of a chat message represents time in the UTC timezone, and was
  /// created by a server. For example, if in Brazil it's 13hs, and in UTC it is 16hs, then the
  /// timestamp will have DayTime 16hs (as if it were created with DayTime.nowUtc()). If we want to
  /// show this timestamp as time in a chat bubble, we need to call fromUtcToLocalTime(), because
  /// it must appear written at 1pm.
  ///
  /// Example 2: The dayTime in the calendar represents information without a timezone. For example,
  /// if in Brazil it is 13hs, and in UTC it is 16hs, then a calendar appointment will have DayTime
  /// 13hs (as if it were created with DayTime.nowInLocalTimezone()). If we want to show this time
  /// on the screen, just use DayTime directly, as it should appear written at 1pm.
  ///
  /// IMPORTANT: Never store dates returned by this method. It should only be used to format dates
  /// on the screen. TODO: Ideally implement LocalDayTime, that only has a formatWith() method.
  @useResult
  DayTime fromUtcToLocalTime() => DayTime.from(_utc(dateTimeUtc.toLocal()));

  bool isOn(Day day) =>
      (day.yearInt == anoInt) && (day.monthInt == mesInt) && (day.dayInt == diaInt);

  @override
  Day get day => Day.from(dateTimeUtc);

  /// Duration until the current time.
  Duration durationUntilNow() => nowUtc().difference(this);

  HourMin toHourMin() => HourMin(h: horaInt, min: minInt);

  @useResult
  DayTime add(Duration duration) => DayTime.from(dateTimeUtc.add(duration));

  @useResult
  DayTime addDays(int numberOfDays) =>
      DayTime(anoInt, mesInt, diaInt + numberOfDays, horaInt, minInt, segInt, millis);

  @useResult
  DayTime addWeeks(int numberOfWeeks) => addDays(numberOfWeeks * 7);

  @useResult
  DayTime addMonths(int numberOfMonths) =>
      DayTime(anoInt, mesInt + numberOfMonths, diaInt, horaInt, minInt, segInt, millis);

  @useResult
  DayTime addYears(int numberOfYears) =>
      DayTime(anoInt + numberOfYears, mesInt, diaInt, horaInt, minInt, segInt, millis);

  @useResult
  DayTime subtract(Duration duration) => DayTime.from(dateTimeUtc.subtract(duration));

  @useResult
  Duration difference(DayTime day) => dateTimeUtc.difference(day.dateTimeUtc);

  bool ifItsInThePast_InTheLocalTimezone() => DayTime.nowInTheLocalTimezone().isAfter(this);

  bool isAfter(DayTime day) => dateTimeUtc.isAfter(day.dateTimeUtc);

  bool isBefore(DayTime day) => dateTimeUtc.isBefore(day.dateTimeUtc);

  bool isAfterOrEqual(DayTime day) => !dateTimeUtc.isBefore(day.dateTimeUtc);

  bool isBeforeOrEqual(DayTime day) => !dateTimeUtc.isAfter(day.dateTimeUtc);

  String formatWith(DateFormat formatter) => formatter.format(dateTimeUtc);

  /// Note: removes microseconds.
  static DateTime _utc(DateTime dateTime) {
    return DateTime.utc(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
      dateTime.millisecond,
      0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayTime && runtimeType == other.runtimeType && dateTimeUtc == other.dateTimeUtc;

  @override
  int get hashCode => dateTimeUtc.hashCode;

  bool operator <(DayTime other) => isBefore(other);

  bool operator >(DayTime other) => isAfter(other);

  bool operator <=(DayTime other) => isBeforeOrEqual(other);

  bool operator >=(DayTime other) => isAfterOrEqual(other);

  DayTime operator +(Duration duration) => add(duration);

  Duration operator -(DayTime other) => difference(other);

  /// First millisecond of the day.
  @useResult
  DayTime dayStart() => DayTime(anoInt, mesInt, diaInt, 0, 0, 0);

  /// Last millisecond of the day.
  @useResult
  DayTime dayEnd() => DayTime(anoInt, mesInt, diaInt, 23, 59, 999);

  /// 1) If the given date is Monday through Friday, return this object.
  /// Otherwise, return the last second of the day, of the previous Friday.
  @useResult
  DayTime mostRecentWorkday() {
    //
    DayOfWeek dayOfWeek = this.dayOfWeek;

    if (dayOfWeek == DayOfWeek.saturday)
      return DayTime(anoInt, mesInt, diaInt - 1, 23, 59, 59, 0);
    //
    else if (dayOfWeek == DayOfWeek.sunday)
      return DayTime(anoInt, mesInt, diaInt - 2, 23, 59, 59, 0);
    //
    else
      return this;
  }

  @override
  int compareTo(DayTime other) => dateTimeUtc.compareTo(other.dateTimeUtc);

  /// Example: var day = Day.parse("2019-06-14 20:42:02.314Z");
  /// It also works if instead of space as a separator it's 'T': "2019-06-14T20:42:02.314Z".
  /// The date MUST end in 'Z', otherwise throws exception.
  static DayTime parse(String formattedString) => (formattedString.endsWith("Z"))
      ? DayTime.convertToUtc(DateTime.parse(formattedString))
      : throw AssertionError("Can only convert from UTC. The string must end with 'Z'.");

  /// Beware when using this, because it will convert adding the local timezone.
  /// It also works if instead of space as a separator it's 'T': "2019-06-14T20:42:02.314".
  /// The date MUST NOT end in 'Z', otherwise throws exception.
  static DayTime parseLocalTimezone(String formattedStringLocal) =>
      (!formattedStringLocal.endsWith("Z"))
          ? DayTime.convertToUtc(DateTime.parse(formattedStringLocal))
          : throw AssertionError("Can only convert from local date, not UTC. "
              "The string must NOT end with 'Z'.");

  static DayTime? parseLocalTimezoneOrNull(String? formattedStringLocal) =>
      (formattedStringLocal == null) ? null : parseLocalTimezone(formattedStringLocal);

  /// Run the callback, simulating clock with this DayTime.
  T withDayTime<T>(T Function() callback) => withClock<T>(Clock.fixed(dateTimeUtc), callback);

  /// Formats in Iso8601, for example: "2014-10-02T15:01:23.045000Z"
  /// Note this format has no spaces, and it's recommended for JSON use.
  /// Equivalent to Firebase's `Timestamp.toString`.
  /// Note: Dart's `DateTime.toString` is similar, but with a space instead of the 'T' letter.
  @override
  String toString() => dateTimeUtc.toIso8601String();

  String hourMinString() => "$horaInt:$minInt";
}
