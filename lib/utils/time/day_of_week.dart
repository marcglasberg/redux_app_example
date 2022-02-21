import 'package:async_redux_project_template/_EXPORT.dart';

class DayOfWeek extends Enumerator {
  //
  const DayOfWeek._(Id id) : super(id);

  /// Given a [Day], return the corresponding day of week.
  factory DayOfWeek.fromDay(Day day) {
    int weekDay = day.weekday;
    return values[weekDay - 1];
  }

  /// Return true if it's Saturday or Sunday.
  bool get isWeekend => this == saturday || this == sunday;

  /// Return true if it's Monday to Friday (does not take holidays into account).
  bool get isWorkDay => !isWeekend;

  /// Given a [DayTime], return the corresponding day of week.
  factory DayOfWeek.fromDayTime(DayTime dayTime) => DayOfWeek.fromDay(dayTime.day);

  static const monday = DayOfWeek._(Id("monday"));
  static const tuesday = DayOfWeek._(Id("tuesday"));
  static const wednesday = DayOfWeek._(Id("wednesday"));
  static const thursday = DayOfWeek._(Id("thursday"));
  static const friday = DayOfWeek._(Id("friday"));
  static const saturday = DayOfWeek._(Id("saturday"));
  static const sunday = DayOfWeek._(Id("sunday"));

  static const values = <DayOfWeek>[...workDays, ...weekend];

  static const workDays = <DayOfWeek>[monday, tuesday, wednesday, thursday, friday];
  static const weekend = <DayOfWeek>[saturday, sunday];

  DayOfWeek next() => const {
        monday: tuesday,
        tuesday: wednesday,
        wednesday: thursday,
        thursday: friday,
        friday: saturday,
        saturday: sunday,
        sunday: monday,
      }[this]!;

  DayOfWeek previous() => const {
        monday: sunday,
        tuesday: monday,
        wednesday: tuesday,
        thursday: wednesday,
        friday: thursday,
        saturday: friday,
        sunday: saturday,
      }[this]!;

  @override
  String text() {
    var text = {
      monday: "Monday",
      tuesday: "Tuesday",
      wednesday: "Wednesday",
      thursday: "Thursday",
      friday: "Friday",
      saturday: "Saturday",
      sunday: "Sunday",
    }[this];

    return (text != null) ? text : throw EnumError(this);
  }
}
