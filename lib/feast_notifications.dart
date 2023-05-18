import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:supercharged/supercharged.dart';

import 'church_calendar.dart';
import 'church_day.dart';
import 'globals.dart';
import 'firebase_config.dart';

class FeastNotifications {
  String lang;
  DateTime date;
  ChurchCalendar cal;

  FeastNotifications(this.date, this.lang) : cal = ChurchCalendar.fromDate(date);

  DateFormat get formatter1 {
    if (lang == 'en') {
      return DateFormat("EEEE, MMM d", lang);
    } else if (lang == 'ru') {
      return DateFormat("cccc, d MMMM", lang);
    } else {
      return DateFormat("M月d日", lang);
    }
  }

  DateFormat get formatter2 {
    if (lang == 'en') {
      return DateFormat("MMMM d", lang);
    } else if (lang == 'ru') {
      return DateFormat("d MMMM", lang);
    } else {
      return DateFormat("M月d日", lang);
    }
  }

  String intervalStr(DateTime from, DateTime to, String descr) =>
      "from_till".tr().format([formatter2.format(from), formatter2.format(to), descr.tr()]);

  String dateStr(DateTime date, [String descr = ""]) => descr.isNotEmpty
      ? "%s — %s".tr().format([formatter1.format(date).capitalize(), descr.tr()])
      : formatter1.format(date).capitalize();

  setup() {
    // long fasts

    FirebaseConfig.schedule(cal.d("beginningOfGreatLent"), "beginningOfGreatLent".tr(),
        intervalStr(cal.greatLentStart, cal.greatLentStart + 47.days, "great_lent"));

    FirebaseConfig.schedule(
        cal.d("beginningOfApostlesFast"),
        "beginningOfApostlesFast".tr(),
        intervalStr(
            cal.d("beginningOfApostlesFast"), cal.d("peterAndPaul") - 1.days, "apostles_fast"));

    FirebaseConfig.schedule(
        cal.d("beginningOfDormitionFast"),
        "beginningOfDormitionFast".tr(),
        intervalStr(
            cal.d("beginningOfDormitionFast"), cal.d("dormition") - 1.days, "dormition_fast"));

    FirebaseConfig.schedule(
        cal.d("beginningOfNativityFast"),
        "beginningOfNativityFast".tr(),
        intervalStr(
            cal.d("beginningOfNativityFast"), cal.d("nativityOfGod") - 1.days, "nativity_fast"));

    // short fasts

    ["eveOfTheophany", "beheadingOfJohn", "exaltationOfCross"].forEach((feast) =>
        FirebaseConfig.schedule(cal.d(feast), dateStr(cal.d(feast), "fast_day"), feast.tr()));

    // fast-free weeks

    FirebaseConfig.schedule(cal.d("nativityOfGod"), "fast_free".tr(),
        intervalStr(cal.d("nativityOfGod"), cal.d("eveOfTheophany") - 1.days, "svyatki"));

    FirebaseConfig.schedule(
        cal.d("sundayOfPublicianAndPharisee") + 1.days,
        "fast_free".tr(),
        intervalStr(cal.d("sundayOfPublicianAndPharisee") + 1.days, cal.d("sundayOfProdigalSon"),
            "weekOfPublicianAndPharisee"));

    FirebaseConfig.schedule(
        cal.d("sundayOfDreadJudgement") + 1.days,
        "fast_free".tr(),
        intervalStr(
            cal.d("sundayOfDreadJudgement") + 1.days, cal.greatLentStart - 1.days, "maslenitsa"));

    FirebaseConfig.schedule(cal.pascha + 1.days, "fast_free".tr(),
        intervalStr(cal.pascha + 1.days, cal.pascha + 7.days, "brightWeek"));

    FirebaseConfig.schedule(cal.pentecost + 1.days, "fast_free".tr(),
        intervalStr(cal.pentecost + 1.days, cal.pentecost + 7.days, "trinityWeek"));

    // great feasts

    [
      "pascha",
      "palmSunday",
      "ascension",
      "pentecost",
      "nativityOfGod",
      "theophany",
      "meetingOfLord",
      "annunciation",
      "transfiguration",
      "dormition",
      "nativityOfTheotokos",
      "entryIntoTemple",
      "circumcision",
      "nativityOfJohn",
      "peterAndPaul",
      "veilOfTheotokos"
    ].forEach((feast) => FirebaseConfig.schedule(cal.d(feast), dateStr(cal.d(feast)), feast.tr()));

    [
      "newMartyrsConfessorsOfRussia",
      "saturdayOfDeparted",
      "radonitsa",
      "killedInAction",
      "saturdayTrinity",
      "demetriusSaturday",
      "saturday2GreatLent",
      "saturday3GreatLent",
      "saturday4GreatLent"
    ].forEach((feast) => FirebaseConfig.schedule(cal.d(feast), dateStr(cal.d(feast)), feast.tr()));

    if (lang == 'en' || lang == 'ru') {
      final vigilDays = cal.days.where((d) =>
          d.name.isEmpty &&
          (d.comment?.isNotEmpty ?? false) &&
          d.type.index >= FeastType.polyeleos.index);

      vigilDays.forEach((d) => FirebaseConfig.schedule(
          d.date!, dateStr(d.date!), "memory_of".tr().format([d.comment!.tr()])));
    }
  }
}
