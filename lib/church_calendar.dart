import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:supercharged/supercharged.dart';
import 'package:easy_localization/easy_localization.dart';

import 'globals.dart';
import 'church_day.dart';

class ChurchCalendar {
  late int year;
  late List<ChurchDay> days;
  late DateTime startOfYear, endOfYear;
  late DateTime greatLentStart, pascha, pentecost;
  late DateTime leapStart, leapEnd;
  late bool isLeapYear;

  static Map<int, ChurchCalendar> calendars = {};

  factory ChurchCalendar.fromDate(DateTime d) {
    var year = d.year;

    if (!ChurchCalendar.calendars.containsKey(year)) {
      ChurchCalendar.calendars[year] = ChurchCalendar(d);
    }

    return ChurchCalendar.calendars[year]!;
  }

  ChurchCalendar(DateTime d) {
    year = d.year;
    JSON.dateParser = dateParser;

    startOfYear = DateTime.utc(year, 1, 1);
    endOfYear = DateTime.utc(year, 12, 31);

    pascha = paschaDay(year);
    greatLentStart = pascha - 48.days;
    pentecost = pascha + 49.days;

    leapStart = DateTime.utc(year, 2, 29);
    leapEnd = DateTime.utc(year, 3, 13);
    isLeapYear = (year % 400) == 0 || ((year % 4 == 0) && (year % 100 != 0));

    initDays();
    initGreatLent();
    initSatSun();
    initMisc();
    initBeforeAfterFeasts();
  }

  DateTime? dateParser(String? date) {
    if ((date?.length ?? 0) > 0) {
      var dd = DateFormat("d MMMM", "en").parse(date!);
      return DateTime.utc(year, dd.month, dd.day);
    } else {
      return null;
    }
  }

  void initDays() {
    List<dynamic> parsed = jsonDecode(JSON.calendar);
    days = List<ChurchDay>.from(parsed.map((i) => ChurchDay.fromJson(i)));

    // log(days.toString());
  }

  void initGreatLent() {
    // TRIODION
    day("sundayOfZacchaeus").date = greatLentStart - 29.days;
    day("sundayOfPublicianAndPharisee").date = greatLentStart - 22.days;
    day("sundayOfProdigalSon").date = greatLentStart - 15.days;
    day("saturdayOfDeparted").date = greatLentStart - 9.days;
    day("sundayOfDreadJudgement").date = greatLentStart - 8.days;
    day("saturdayOfFathers").date = greatLentStart - 2.days;
    day("cheesefareSunday").date = greatLentStart - 1.days;

    // GREAT LENT
    day("beginningOfGreatLent").date = greatLentStart;
    day("saturday1GreatLent").date = greatLentStart + 5.days;
    day("sunday1GreatLent").date = greatLentStart + 6.days;
    day("saturday2GreatLent").date = greatLentStart + 12.days;
    day("sunday2GreatLent").date = greatLentStart + 13.days;
    day("saturday3GreatLent").date = greatLentStart + 19.days;
    day("sunday3GreatLent").date = greatLentStart + 20.days;
    day("saturday4GreatLent").date = greatLentStart + 26.days;
    day("sunday4GreatLent").date = greatLentStart + 27.days;
    day("thursday5GreatLent").date = greatLentStart + 31.days;
    day("saturday5GreatLent").date = greatLentStart + 33.days;
    day("sunday5GreatLent").date = greatLentStart + 34.days;

    day("lazarusSaturday").date = pascha - 8.days;
    day("palmSunday").date = pascha - 7.days;
    days.add(ChurchDay("greatMonday", FeastType.none, date: pascha - 6.days));
    days.add(ChurchDay("greatTuesday", FeastType.none, date: pascha - 5.days));
    days.add(ChurchDay("greatWednesday", FeastType.none, date: pascha - 4.days));
    days.add(ChurchDay("greatThursday", FeastType.none, date: pascha - 3.days));
    days.add(ChurchDay("greatFriday", FeastType.none, date: pascha - 2.days));
    days.add(ChurchDay("greatSaturday", FeastType.none, date: pascha - 1.days));

    // PASCHA
    day("pascha").date = pascha;
    day("sunday2AfterPascha").date = pascha + 7.days;
    day("radonitsa").date = pascha + 9.days;
    day("sunday3AfterPascha").date = pascha + 14.days;
    day("sunday4AfterPascha").date = pascha + 21.days;
    days.add(ChurchDay("midPentecost", FeastType.none, date: pascha + 24.days));
    day("sunday5AfterPascha").date = pascha + 28.days;
    day("sunday6AfterPascha").date = pascha + 35.days;
    day("ascension").date = pascha + 39.days;
    day("sunday7AfterPascha").date = pascha + 42.days;
    day("saturdayTrinity").date = pascha + 48.days;

    // PENTECOST
    day("pentecost").date = pascha + 49.days;
    days.add(ChurchDay("holySpirit", FeastType.none, date: pentecost + 1.days));
    day("beginningOfApostlesFast").date = pentecost + 8.days;
    day("sunday1AfterPentecost").date = pentecost + 7.days;
    day("sunday2AfterPentecost").date = pentecost + 14.days;
  }

  void initSatSun() {
    ChurchDay saturdayBeforeNativity(DateTime date) =>
        ChurchDay("saturdayBeforeNativity", FeastType.none,
            date: date, reading: "Gal 3:8-12 Luke 13:18-29 # Saturday before the Nativity");

    ChurchDay sundayBeforeNativity(DateTime date) =>
        ChurchDay("sundayBeforeNativity", FeastType.none,
            date: date,
            reading: "Heb 11:9-10,17-23,32-40 Matthew 1:1-25 # Sunday before the Nativity");

    // EXALTATION SAT & SUN
    var exaltation = DateTime.utc(year, 9, 27);
    day("sundayAfterExaltation").date = nearestSundayAfter(exaltation);
    day("saturdayAfterExaltation").date = nearestSaturdayAfter(exaltation);
    day("sundayBeforeExaltation").date = nearestSundayBefore(exaltation);
    day("saturdayBeforeExaltation").date = nearestSaturdayBefore(exaltation);

    // NATIVITY SAT & SUN
    var nativity = DateTime.utc(year, 1, 7);
    day("sundayAfterNativity").date = nearestSundayAfter(nativity);
    day("saturdayAfterNativity").date = nearestSaturdayAfter(nativity);

    days.add(saturdayBeforeNativity(nearestSaturdayBefore(nativity)));
    days.add(sundayBeforeNativity(nearestSundayBefore(nativity)));

    if (nativity.weekday == DateTime.sunday) {
      day("josephBetrothed").date = nativity + 1.days;
    } else {
      day("josephBetrothed").date = nearestSundayAfter(nativity);
    }

    var nativityNextYear = DateTime.utc(year + 1, 1, 7);
    var nativitySunNextYear = nearestSundayBefore(nativityNextYear);

    days.add(saturdayBeforeNativity(nearestSaturdayBefore(nativityNextYear)));
    days.add(sundayBeforeNativity(nearestSundayBefore(nativityNextYear)));

    day("sundayOfForefathers").date = nativitySunNextYear - 7.days;

    // THEOPHANY SAT & SUN
    var theophany = DateTime.utc(year, 1, 19);
    day("sundayAfterTheophany").date = nearestSundayAfter(theophany);
    day("saturdayAfterTheophany").date = nearestSaturdayAfter(theophany);
    day("sundayBeforeTheophany").date = nearestSundayBefore(theophany);
    day("saturdayBeforeTheophany").date = nearestSaturdayBefore(theophany);
  }

  void initMisc() {
    var demetrius = DateTime.utc(year, 11, 8);
    day("demetriusSaturday").date = nearestSaturdayBefore(demetrius);

    day("newMartyrsConfessorsOfRussia").date = nearestSunday(DateTime.utc(year, 2, 7));
    day("holyFathersSixCouncils").date = nearestSunday(DateTime.utc(year, 7, 29));
    day("holyFathersSeventhCouncil").date = nearestSunday(DateTime.utc(year, 10, 24));

    // SYNAXIS
    days.add(ChurchDay("synaxisKievCavesSaints", FeastType.none, date: greatLentStart + 13.days));
    days.add(ChurchDay("synaxisMartyrsButovo", FeastType.none, date: pascha + 27.days));
    days.add(ChurchDay("synaxisMountAthosSaints", FeastType.none, date: pentecost + 14.days));

    days.add(ChurchDay("synaxisMoscowSaints", FeastType.none,
        date: nearestSundayBefore(DateTime.utc(year, 9, 8))));
    days.add(ChurchDay("synaxisNizhnyNovgorodSaints", FeastType.none,
        date: nearestSundayAfter(DateTime.utc(year, 9, 7))));

    var synaxisTheotokos = DateTime.utc(year, 1, 8);

    if (synaxisTheotokos.weekday == DateTime.monday) {
      days.add(ChurchDay("", FeastType.doxology,
          date: synaxisTheotokos, reading: "Heb 2:11-18 # Theotokos"));
      days.add(ChurchDay("", FeastType.doxology,
          date: synaxisTheotokos, reading: "Gal 1:11-19 Matthew 2:13-23 # Holy Ancestors"));
    } else if (synaxisTheotokos.weekday != DateTime.sunday) {
      days.add(ChurchDay("", FeastType.doxology,
          date: synaxisTheotokos, reading: "Heb 2:11-18 Matthew 2:13-23 # Theotokos"));
    }

    days.add(ChurchDay("josephArimathea", FeastType.noSign, date: pascha + 14.days));
    days.add(ChurchDay("tamaraGeorgia", FeastType.noSign, date: pascha + 14.days));
    days.add(ChurchDay("abrahamBulgar", FeastType.noSign, date: pascha + 21.days));
    days.add(ChurchDay("tabithaJoppa", FeastType.noSign, date: pascha + 21.days));

    // ICONS OF THEOTOKOS
    days.add(ChurchDay("iveronTheotokos", FeastType.none, date: pascha + 2.days));
    days.add(ChurchDay("springTheotokos", FeastType.none, date: pascha + 5.days));
    days.add(ChurchDay("mozdokTheotokos", FeastType.none, date: pascha + 24.days));
    days.add(ChurchDay("chelnskoyTheotokos", FeastType.none, date: pascha + 42.days));
    days.add(ChurchDay("tupichevskTheotokos", FeastType.none, date: pentecost + 1.days));
    days.add(ChurchDay("koretsTheotokos", FeastType.none, date: pentecost + 4.days));
    days.add(ChurchDay("softenerTheotokos", FeastType.none, date: pentecost + 7.days));
  }

  void generateBeforeAfter(
      {required String feast,
      int daysBefore = 0,
      FeastType signBefore = FeastType.noSign,
      int daysAfter = 0,
      FeastType signAfter = FeastType.noSign,
      FeastType signApodosis = FeastType.doxology}) {
    var date = d(feast);
    var eve1 = d("eveOfNativityOfGod");
    var eve2 = d("eveOfTheophany");

    if (daysBefore > 0) {
      for (final forefeast in (date - daysBefore.days).rangeTo(date - 1.days)) {
        if (forefeast != eve1 && forefeast != eve2) {
          days.add(ChurchDay("forefeast_$feast", signBefore, date: forefeast));
        }
      }
    }

    if (daysAfter > 0) {
      for (final afterfeast in (date + 1.days).rangeTo(date + daysAfter.days)) {
        days.add(ChurchDay("afterfeast_$feast", signAfter, date: afterfeast));
      }
    }

    days.add(ChurchDay("apodosis_$feast", signApodosis, date: date + (daysAfter + 1).days));
  }

  void initBeforeAfterFeasts() {
    days.add(ChurchDay("apodosis_pascha", FeastType.none, date: pascha + 38.days));

    generateBeforeAfter(
        feast: "ascension", daysAfter: 7, signAfter: FeastType.none, signApodosis: FeastType.none);
    generateBeforeAfter(
        feast: "pentecost", daysAfter: 5, signAfter: FeastType.none, signApodosis: FeastType.none);
    generateBeforeAfter(feast: "nativityOfGod", daysBefore: 5, daysAfter: 5);
    generateBeforeAfter(
        feast: "theophany", daysBefore: 4, daysAfter: 7, signApodosis: FeastType.noSign);
    generateBeforeAfter(
        feast: "transfiguration", daysBefore: 1, signBefore: FeastType.sixVerse, daysAfter: 6);
    generateBeforeAfter(
        feast: "dormition", daysBefore: 1, signBefore: FeastType.sixVerse, daysAfter: 7);
    generateBeforeAfter(
        feast: "nativityOfTheotokos", daysBefore: 1, signBefore: FeastType.sixVerse, daysAfter: 3);
    generateBeforeAfter(feast: "exaltationOfCross", daysBefore: 1, daysAfter: 6);
    generateBeforeAfter(feast: "entryIntoTemple", daysBefore: 1, daysAfter: 3);

    var annunciation = d("annunciation");

    if (annunciation.isBetween(greatLentStart, d("lazarusSaturday") - 1.days)) {
      days.add(
          ChurchDay("forefeast_annunciation", FeastType.sixVerse, date: annunciation - 1.days));
      days.add(ChurchDay("apodosis_annunciation", FeastType.doxology, date: annunciation + 1.days));
    } else if (annunciation == d("lazarusSaturday")) {
      days.add(
          ChurchDay("forefeast_annunciation", FeastType.sixVerse, date: annunciation - 1.days));
    }

    var meetingOfLord = d("meetingOfLord");
    days.add(
        ChurchDay("forefeast_meetingOfLord", FeastType.sixVerse, date: meetingOfLord - 1.days));

    var lastDay = meetingOfLord;

    if (meetingOfLord.isBetween(startOfYear, d("sundayOfProdigalSon") - 2.days)) {
      lastDay = meetingOfLord + 7.days;
    } else if (meetingOfLord.isBetween(
        d("sundayOfProdigalSon") - 1.days, d("sundayOfProdigalSon") + 2.days)) {
      lastDay = d("sundayOfProdigalSon") + 5.days;
    } else if (meetingOfLord.isBetween(
        d("sundayOfProdigalSon") + 3.days, d("sundayOfDreadJudgement") - 1.days)) {
      lastDay = d("sundayOfDreadJudgement") + 2.days;
    } else if (meetingOfLord.isBetween(
        d("sundayOfDreadJudgement"), d("sundayOfDreadJudgement") + 1.days)) {
      lastDay = d("sundayOfDreadJudgement") + 4.days;
    } else if (meetingOfLord.isBetween(
        d("sundayOfDreadJudgement") + 2.days, d("sundayOfDreadJudgement") + 3.days)) {
      lastDay = d("sundayOfDreadJudgement") + 6.days;
    } else if (meetingOfLord.isBetween(
        d("sundayOfDreadJudgement") + 4.days, d("sundayOfDreadJudgement") + 6.days)) {
      lastDay = d("cheesefareSunday");
    }

    if (lastDay != meetingOfLord) {
      for (final afterfeast in (meetingOfLord + 1.days).rangeTo(lastDay - 1.days)) {
        days.add(ChurchDay("afterfeast_meetingOfLord", FeastType.noSign, date: afterfeast));
      }

      days.add(ChurchDay("apodosis_meetingOfLord", FeastType.doxology, date: lastDay));
    }
  }

  static DateTime paschaDay(int year) {
    final a = (19 * (year % 19) + 15) % 30;
    final b = (2 * (year % 4) + 4 * (year % 7) + 6 * a + 6) % 7;

    return ((a + b > 10) ? DateTime.utc(year, 4, a + b - 9) : DateTime.utc(year, 3, 22 + a + b)) + 13.days;
  }

  static DateTime nearestSundayBefore(DateTime d) => d - d.weekday.days;
  static DateTime nearestSaturdayBefore(DateTime d) =>
      d.weekday == DateTime.sunday ? d - 1.days : d - (d.weekday + 1).days;

  static DateTime nearestSundayAfter(DateTime d) =>
      d.weekday == DateTime.sunday ? d + 7.days : d + (7 - d.weekday).days;

  static DateTime nearestSaturdayAfter(DateTime d) =>
      d.weekday == DateTime.saturday || d.weekday == DateTime.sunday
          ? d + (13 - d.weekday).days
          : d + (6 - d.weekday).days;

  static DateTime nearestSunday(DateTime d) {
    switch (d.weekday) {
      case DateTime.sunday:
        return d;

      case DateTime.monday:
      case DateTime.tuesday:
      case DateTime.wednesday:
        return nearestSundayBefore(d);

      default:
        return nearestSundayAfter(d);
    }
  }

  static List<ChurchDay> getGreatFeast(DateTime d) =>
      Cal.fromDate(d).days.where((e) => e.date == d && e.type == FeastType.great).toList();
}

extension ChurchCalendarFunc on ChurchCalendar {
  ChurchDay day(String name) => days.where((e) => e.name == name).first;

  DateTime d(String name) => day(name).date!;

  List<ChurchDay> getDayDescription(DateTime d) =>
      (days.where((e) => e.date == d && e.name.isNotEmpty).toList()
            ..sort((a, b) => a.type.index - b.type.index))
          .toList();

  List<ChurchDay> getDayReadings(DateTime d) =>
      (days.where((e) => e.date == d && e.reading != null).toList()
            ..sort((a, b) => b.type.index - a.type.index))
          .toList();

  List<ChurchDay> getAllReadings() => days.where((e) => e.reading != null).toList();

  String? getWeekDescription(DateTime date) {
    final dayOfWeek = (date.weekday == DateTime.sunday) ? "Sunday" : "Week";

    if (date.isBetween(startOfYear, d("sundayOfPublicianAndPharisee") - 1.days)) {
      return "${dayOfWeek}AfterPentecost"
          .tr()
          .format([((Cal.paschaDay(year - 1) + 50.days) >> date) ~/ 7 + 1]);
    } else if (date.isBetween(
        d("sundayOfPublicianAndPharisee") + 1.days, d("sundayOfProdigalSon") - 1.days)) {
      return "weekOfPublicianAndPharisee".tr();
    } else if (date.isBetween(
        d("sundayOfProdigalSon") + 1.days, d("sundayOfDreadJudgement") - 1.days)) {
      return "weekOfProdigalSon".tr();
    } else if (date.isBetween(
        d("sundayOfDreadJudgement") + 1.days, d("cheesefareSunday") - 1.days)) {
      return "weekOfDreadJudgement".tr();
    } else if (date.isBetween(d("beginningOfGreatLent"), d("palmSunday") - 1.days)) {
      return "${dayOfWeek}OfGreatLent".tr().format([(greatLentStart >> date) ~/ 7 + 1]);
    } else if (date.isBetween(d("palmSunday") + 1.days, pascha - 1.days)) {
      return "holyWeek".tr();
    } else if (date.isBetween(pascha + 1.days, pascha + 6.days)) {
      return "brightWeek".tr();
    } else if (date.isBetween(pascha + 8.days, pentecost - 1.days)) {
      return (date.weekday == DateTime.sunday)
          ? null
          : "WeekAfterPascha".tr().format([(pascha >> date) ~/ 7 + 1]);
    } else if (date.isBetween(pentecost + 1.days, endOfYear)) {
      return "${dayOfWeek}AfterPentecost".tr().format([((pentecost + 1.days) >> date) ~/ 7 + 1]);
    } else {
      return null;
    }
  }

  int? getTone(DateTime date) {
    int tone(int dayNum) {
      final reminder = (dayNum ~/ 7) % 8;
      return (reminder == 0) ? 8 : reminder;
    }

    if (date.isBetween(startOfYear, d("palmSunday") - 1.days)) {
      return tone(Cal.paschaDay(year - 1) >> date);
    } else if (date.isBetween(pascha + 7.days, endOfYear)) {
      return tone(pascha >> date);
    } else {
      return null;
    }
  }

  String? getToneDescription(DateTime date) {
    final tone = getTone(date);
    return (tone != null) ? "tone".tr().format([tone]) : null;
  }
}

typedef Cal = ChurchCalendar;
