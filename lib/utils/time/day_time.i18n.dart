import "package:i18n_extension/i18n_extension.dart";
import "package:i18n_extension/i18n_widget.dart";
import "package:intl/intl.dart";
import "day_time.dart";

////////////////////////////////////////////////////////////////////////////////////////////////////

const String space = " ";

const String twoSpaces = "$space$space";

////////////////////////////////////////////////////////////////////////////////////////////////////

extension _Localization on String {
  //

  static final _t = Translations("pt_br") +
      {
        "pt_br": "manhã",
        "en_us": "morning",
      } +
      {
        "pt_br": "tarde",
        "en_us": "afternoon",
      } +
      {
        "pt_br": "noite",
        "en_us": "night",
      };

  String get i18n => localize(this, _t);
}

////////////////////////////////////////////////////////////////////////////////////////////////////

extension Localization_DayTimeNullable on DayTime? {
  //
  String formatHourMin_ET({String ifNull = ''}) {
    DayTime? dayTime = this;
    return (dayTime == null) //
        ? ifNull
        : dayTime.formatWith(DateFormat('h:mm a'));
  }

  String formatHourMinSec_ET({String ifNull = ''}) {
    DayTime? dayTime = this;
    return (dayTime == null) //
        ? ifNull
        : dayTime.formatWith(DateFormat('h:mm:ss a'));
  }

  String formatYMD_ET({String ifNull = ''}) {
    DayTime? dayTime = this;
    return (dayTime == null) //
        ? ifNull
        : dayTime.formatWith(DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY));
  }

  String formatYyyyMmDd_ET({String ifNull = ''}) {
    DayTime? dayTime = this;
    return (dayTime == null) //
        ? ifNull
        : dayTime.formatWith(DateFormat('yyyy-MM-dd'));
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

extension Localization_DayTime on DayTime {
  //
  static bool get ifIs12HourFormat =>
      DateFormat("j", I18n.localeStr).format(DateTime(2000, 1, 1, 10, 0)).endsWith("AM");

  /// In 24-hour format, returns the time "hh:mm".
  /// In 12-hour format, returns the time "hh:mm AM" or "hh:mm PM".
  /// If you want to remove the initial zero, it would yield "8:30" instead of "08:30",
  /// and day start would be "0:00", not "00:00".
  /// Se [amPmSeparator] is given, return something like "hh:mm*PM*".
  ///
  String formatTime({
    bool ifRemoveInitialZero = false,
    bool ifRemoveSpace = false,
    String? amPmSeparator,
  }) {
    var formatTime = DateFormat.jm(I18n.localeStr);
    var time = formatWith(formatTime);

    if (ifRemoveInitialZero && time.startsWith("0")) time = time.substring(1);

    if (time.contains("M")) {
      // "hh:mm PM" → "hh:mm *PM*"
      if (amPmSeparator != null) {
        if (ifRemoveSpace)
          time = time.replaceFirst(space, amPmSeparator) + amPmSeparator;
        else
          time = time.replaceFirst(space, space + amPmSeparator) + amPmSeparator;
      }
      // "hh:mm PM" → "hh:mmPM"
      else if (ifRemoveSpace) time = time.replaceFirst(" ", "");
    }

    return time;
  }

  String formatMorningAfternoonNight() {
    if (horaInt <= 11)
      return "manhã".i18n;
    else if ((horaInt < 18) || (horaInt == 18 && minInt <= 30))
      return "tarde".i18n;
    else
      return "noite".i18n;
  }

  /// In 24-hour format, returns a list containing the time (hh:mm), and null.
  /// In 12-hour format, returns a list containing the time (hh:mm), and "AM" or "PM".
  List<String?> fazSplitDeAmPm({bool IfRemoveInitialZero = false}) {
    //
    var timeStr = formatTime(ifRemoveInitialZero: IfRemoveInitialZero);

    // 12-hour.
    if (timeStr.contains("AM")) {
      return [timeStr.replaceFirst("AM", "").trim(), "AM"];
    }

    // 12-hour.
    else if (timeStr.contains("PM")) {
      return [timeStr.replaceFirst("PM", "").trim(), "PM"];
    }

    // 24-hour.
    else {
      return [timeStr, null];
    }
  }
}
