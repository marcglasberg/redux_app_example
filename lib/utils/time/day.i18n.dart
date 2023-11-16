import 'package:async_redux_project_template/_EXPORT.dart';
import "package:i18n_extension/i18n_extension.dart";
import "package:i18n_extension/i18n_widget.dart";
import "package:intl/intl.dart";



extension _Localization on String {
  //
  static final _t = Translations("pt_br") +
      {
        "pt_br": "(há %d dias)",
        "en_us": "(%d days ago)",
      } +
      {
        "pt_br": "Hoje",
        "en_us": "Today",
      } +
      {
        "pt_br": "Amanhã",
        "en_us": "Tomorrow",
      } +
      {
        "pt_br": "Há %d dias".one("Ontem").many("Há %d dias"),
        "en_us": "%d days ago".one("Yesterday").many("%d days ago"),
      } +
      {
        "pt_br": "Em %d dias".one("Amanhã").many("Em %d dias"),
        "en_us": "In %d days".one("Tomorrow").many("In %d days"),
      } +
      {
        "pt_br": "Há %d semanas".one("Há 1 semana").many("Há %d semanas"),
        "en_us": "%d weeks ago".one("1 week ago").many("%d weeks ago"),
      } +
      {
        "pt_br": "Em %d semanas".one("Em 1 semana").many("Em %d semanas"),
        "en_us": "In %d weeks".one("In 1 week").many("In %d weeks"),
      } +
      {
        "pt_br": "Há %d mêses".one("Há 1 mês").many("Há %d mêses"),
        "en_us": "%d months ago".one("1 month ago").many("%d months ago"),
      } +
      {
        "pt_br": "Em %d mêses".one("Em 1 mês").many("Em %d mêses"),
        "en_us": "In %d months".one("In 1 month").many("In %d months"),
      };

  String get i18n => localize(this, _t);

  String plural(int value) => localizePlural(value, this, _t);

  // ignore: unused_element
  String fill(int params) => localizeFill(this, [params]);
}



extension Localization_DayNullable on Day? {
  //
  String formatYMD_ET() {
    return (this == null) //
        ? '-'
        : this!.formatWith(DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY));
  }
}



extension Localization_Day on Day {
  //
  /// Today, Tomorrow, In 2 days, Yesterday, 2 days ago.
  String formatDaysSinceToday() {
    int dif = difference(Day.todayInTheLocalTimezone()).inDays;
    //
    if (I18n.localeStr == "pt_br") {
      if (dif == 0)
        return "hoje";
      else if (dif == 1)
        return "amanhã";
      else if (dif == -1)
        return "ontem";
      else if (dif > 0)
        return "em $dif dias";
      else if (dif < 0) return "há ${dif.abs()} dias";
    } else {
      if (dif == 0)
        return "today";
      else if (dif == 1)
        return "tomorrow";
      else if (dif == -1)
        return "yesterday";
      else if (dif > 0)
        return "in $dif days";
      else if (dif < 0) return "${dif.abs()} days ago";
    }

    throw AssertionError(dif);
  }

  /// The default is firs letter capitalized.
  String formatDayOfWeek({
    bool ifAbbreviated = true,
    Capitalize capitalize = Capitalize.firstLetterUpper,
  }) {
    DateFormat format =
        DateFormat(ifAbbreviated ? DateFormat.ABBR_WEEKDAY : DateFormat.WEEKDAY, I18n.localeStr);

    return formatWith(format).capitalize(capitalize);
  }

  /// The default is firs letter capitalized.
  String formatMonth({
    bool ifAbbreviated = true,
    Capitalize capitalize = Capitalize.firstLetterUpper,
  }) {
    DateFormat format =
        DateFormat(ifAbbreviated ? DateFormat.ABBR_MONTH : DateFormat.MONTH, I18n.localeStr);

    return formatWith(format).capitalize(capitalize);
  }

  String formatDayOfMonthAndMonth() {
    DateFormat format = DateFormat(DateFormat.MONTH_DAY, I18n.localeStr);
    return formatWith(format);
  }

  String formatDayOfMonthAndMonthAndYear() {
    DateFormat format = DateFormat(DateFormat.MONTH_DAY, I18n.localeStr);
    return "${formatWith(format)}, $yearInt";
  }

  /// Return strings for special dates, such as Today, Tomorrow, etc. Otherwise, return null.
  /// If [inRelationTo] is null, will use today in the local-timezone.
  String? formatSpecialDates([Day? inRelationTo]) => _SpecialDates(this).format(inRelationTo);

  String formatNumOfDaysSinceToday([Day? inRelationTo]) =>
      _SpecialDates(this).formatNumOfDaysSinceToday(inRelationTo);
}



class _SpecialDates {
  //
  final Day day;

  _SpecialDates(this.day);

  /// Strings for special dates:
  /// 1) Today
  /// 2) Tomorrow
  /// 3) Week multiples
  /// 4) Month multiples
  /// 5) null = not a special date.
  ///
  String? format([Day? inRelationTo]) {
    inRelationTo ??= Day.todayInTheLocalTimezone();
    int diff = day.difference(inRelationTo).inDays;

    // TODAY:
    if (diff == 0)
      return "Hoje".i18n;

    // TOMORROW:
    else if (diff == 1)
      return "Amanhã".i18n;

    // WEEKS:
    else if (diff % 7 == 0) {
      var weekDiff = diff ~/ 7;
      return formatNumOfWeeksSinceToday(weekDiff);
    }

    // MONTHS:
    else if (inRelationTo.ifIsExactMonthsTo(day)) {
      var monthsDiff = (diff.toDouble() * 12 / 365).round();
      return formatNumOfMonthsSinceToday(monthsDiff);
    }

    // NOT A SPECIAL DATE:
    else
      return null;
  }

  String formatNumOfDaysSinceToday([Day? inRelationTo]) {
    inRelationTo ??= Day.todayInTheLocalTimezone();
    int diff = day.difference(inRelationTo).inDays;

    if (diff < 0) {
      return "Há %d dias".plural(-diff);
    } else if (diff > 0) {
      return "Em %d dias".plural(diff);
    } else {
      return '';
    }
  }

  String formatNumOfWeeksSinceToday(int weeks) {
    if (weeks < 0)
      return "Há %d semanas".plural(-weeks);
    else if (weeks > 0)
      return "Em %d semanas".plural(weeks);
    else
      return '';
  }

  String formatNumOfMonthsSinceToday(int months) {
    if (months < 0)
      return "Há %d mêses".plural(-months);
    else if (months > 0)
      return "Em %d mêses".plural(months);
    else
      return '';
  }
}


