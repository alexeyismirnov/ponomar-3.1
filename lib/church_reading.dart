import 'package:supercharged/supercharged.dart';

import 'dart:convert';
import 'package:intl/intl.dart';

import 'church_calendar.dart';
import 'church_day.dart';
import 'globals.dart';

class LukeSpringParams {
  late DateTime PAPSunday;
  late DateTime pentecostPrevYear;
  late DateTime sundayAfterExaltationPrevYear;
  late int totalOffset;

  LukeSpringParams(Cal cal) {
    PAPSunday = cal.d("sundayOfPublicianAndPharisee");
    pentecostPrevYear = Cal.paschaDay(cal.year - 1) + 50.days;

    var exaltationPrevYear = DateTime.utc(cal.year - 1, 9, 27);
    var exaltationPrevYearWeekday = exaltationPrevYear.weekday;

    sundayAfterExaltationPrevYear = exaltationPrevYear + (8 - exaltationPrevYearWeekday).days;
    var endOfLukeReadings = sundayAfterExaltationPrevYear + 112.days;
    totalOffset = endOfLukeReadings >> PAPSunday;
  }
}

class ChurchReading {
  late Cal cal;
  late LukeSpringParams LS;
  Map<DateTime, List<String>> rr = {};
  late List<String> apostle, readingsJohn, gospelMatthew, gospelLuke, readingsLent;

  static Map<int, ChurchReading> models = {};

  ChurchReading(DateTime d) {
    cal = Cal.fromDate(d);
    LS = LukeSpringParams(cal);

    apostle = List<String>.from(json.decode(JSON.apostle));
    readingsJohn = List<String>.from(json.decode(JSON.readingsJohn));
    gospelMatthew = List<String>.from(json.decode(JSON.gospelMatthew));
    gospelLuke = List<String>.from(json.decode(JSON.gospelLuke));
    readingsLent = List<String>.from(json.decode(JSON.readingsLent));

    generateRR();

    generateTransfers();
  }

  String GospelOfLent(DateTime date) {
    final dayNum = cal.d("sundayOfPublicianAndPharisee") >> date;
    return readingsLent[dayNum];
  }

  String GospelOfJohn(DateTime date) {
    final dayNum = cal.pascha >> date;
    return readingsJohn[dayNum];
  }

  String GospelOfMatthew(DateTime date) {
    var dayNum = (cal.pentecost + 1.days) >> date;
    var readings = apostle[dayNum] + " ";

    if (dayNum >= 17 * 7) dayNum = dayNum - 7 * 7;

    readings += gospelMatthew[dayNum];
    return readings;
  }

  String GospelOfLukeSpring(DateTime date) {
    int gospelIndex, apostleIndex;

    final daysFromPentecost = LS.pentecostPrevYear >> date;
    final daysFromExaltation = (LS.sundayAfterExaltationPrevYear + 1.days) >> date;
    final daysBeforePAP = date >> LS.PAPSunday;

    if (daysFromExaltation >= 16 * 7 - 1) {
      // need more than three additional Sundays, use 17th week Matthew readings
      if (LS.totalOffset > 28) {
        if (daysBeforePAP < 21 && daysBeforePAP >= 14) {
          final indexMatthew = 118 - (daysBeforePAP - 14);
          return apostle[indexMatthew] + " " + gospelMatthew[indexMatthew];
        } else if (daysBeforePAP >= 21) {
          gospelIndex = 118 - daysBeforePAP;
          apostleIndex = 237 - daysBeforePAP;
          return apostle[apostleIndex] + " " + gospelLuke[gospelIndex];
        }
      }

      gospelIndex = 111 - daysBeforePAP;
      apostleIndex = 230 - daysBeforePAP;
    } else if (daysFromPentecost >= 33 * 7 - 1) {
      gospelIndex = daysFromExaltation;
      apostleIndex = 230 - daysBeforePAP;
    } else {
      gospelIndex = daysFromExaltation;
      apostleIndex = daysFromPentecost;
    }

    return apostle[apostleIndex] + " " + gospelLuke[gospelIndex];
  }

  String GospelOfLukeFall(DateTime date) {
    if (date == cal.d("sundayOfForefathers")) {
      return apostle[202] + " " + gospelLuke[76];
    }

    var daysFromPentecost = (cal.pentecost + 1.days) >> date;
    var daysFromLukeStart = (cal.d("sundayAfterExaltation") + 1.days) >> date;

    // On 29th Sunday borrow Epistle from Sunday of Forefathers
    if (daysFromPentecost == 202) {
      daysFromPentecost = (cal.pentecost + 1.days) >> cal.d("sundayOfForefathers");
    }

    // On 28th Sunday borrow Gospel from Sunday of Forefathers
    if (daysFromLukeStart == 76) {
      daysFromLukeStart = (cal.d("sundayAfterExaltation") + 1.days) >> cal.d("sundayOfForefathers");
    }

    return apostle[daysFromPentecost] + " " + gospelLuke[daysFromLukeStart];
  }

  String? getRegularReading(DateTime date) {
    if (date.isBetween(cal.startOfYear, cal.d("sundayOfPublicianAndPharisee") - 1.days)) {
      return GospelOfLukeSpring(date);
    } else if (date.isBetween(cal.d("sundayOfPublicianAndPharisee"), cal.pascha - 1.days)) {
      final reading = GospelOfLent(date);
      return reading.isNotEmpty ? reading : null;
    } else if (date.isBetween(cal.pascha, cal.pentecost)) {
      final reading = GospelOfJohn(date);
      return reading.isNotEmpty ? reading : null;
    } else if (date.isBetween(cal.pentecost + 1.days, cal.d("sundayAfterExaltation"))) {
      return GospelOfMatthew(date);
    } else if (date.isBetween(cal.d("sundayAfterExaltation") + 1.days, cal.endOfYear)) {
      return GospelOfLukeFall(date);
    } else {
      return "";
    }
  }

  generateRR() {
    for (final d in (cal.startOfYear).rangeTo(cal.endOfYear)) {
      final date = DateTime.utc(d.year, d.month, d.day);
      final r = getRegularReading(date);
      if (r != null) rr[date] = [r];
    }
  }

  generateTransfers() {
    var formatter = DateFormat.EEEE("en");

    rr[DateTime.utc(cal.year, 1, 6)] = [];
    rr[DateTime.utc(cal.year, 1, 7)] = [];
    rr[DateTime.utc(cal.year, 1, 14)] = [];
    rr[DateTime.utc(cal.year, 1, 18)] = [];
    rr[DateTime.utc(cal.year, 1, 19)] = [];

    for (final feast in cal.getAllReadings()) {
      final date = feast.date!;

      // combine regular and feast's readings on these dates
      if (date.isBetween(cal.greatLentStart, cal.pentecost) ||
          date == cal.d("sundayOfZacchaeus") ||
          date == cal.d("sundayOfPublicianAndPharisee") ||
          date == cal.d("sundayOfProdigalSon") ||
          date == cal.d("sundayOfDreadJudgement") ||
          date == cal.d("cheesefareSunday")) {
        continue;
      }

      if (feast.type == FeastType.vigil ||
          feast.type == FeastType.great &&
              (feast.name == "veilOfTheotokos" ||
                  feast.name == "nativityOfJohn" ||
                  feast.name == "beheadingOfJohn" ||
                  feast.name == "peterAndPaul" ||
                  feast.name == "dormition" ||
                  feast.name == "nativityOfTheotokos" ||
                  feast.name == "annunciation" ||
                  feast.name == "entryIntoTemple")) {
        final newDate = transferVigil(date);
        final oldReading = rr[date]!;

        if (oldReading.isNotEmpty && newDate != date) {
          final comment = "# %s Reading".format([formatter.format(date)]);

          for (final r in oldReading) {
            rr[newDate]!.add("%s %s".format([r, comment]));
          }

          rr[date] = [];
        }
      } else if (feast.type == FeastType.great) {
        final newDate = transferGreatFeast(date);

        final oldReading = rr[date]!;

        if (oldReading.isNotEmpty && newDate != null) {
          final comment = "# %s Reading".format([formatter.format(date)]);

          for (final r in oldReading) {
            rr[newDate]!.add("%s %s".format([r, comment]));
          }
        }

        rr[date] = [];
      }
    }
  }

  DateTime? transferGreatFeast(DateTime date) {
    DateTime newDate;

    if (date.weekday == DateTime.sunday) {
      return null;
    } else if (date.weekday == DateTime.monday) {
      newDate = date + 1.days;

      if (cal.getDayReadings(newDate).isNotEmpty) {
        return null;
      }
    } else {
      newDate = date - 1.days;
      if (cal.getDayReadings(newDate).isNotEmpty) {
        return null;
      }
    }

    return newDate;
  }

  DateTime transferVigil(DateTime date) {
    DateTime newDate;

    if (date.weekday == DateTime.sunday) {
      return date;
    } else if (date.weekday == DateTime.monday) {
      newDate = date + 1.days;

      if (cal.getDayReadings(newDate).isNotEmpty) {
        return date;
      }
    } else {
      newDate = date - 1.days;
      if (cal.getDayReadings(newDate).isNotEmpty) {
        newDate = date + 1.days;

        if (date.weekday == DateTime.saturday || cal.getDayReadings(newDate).isNotEmpty) {
          return date;
        }
      }
    }

    return newDate;
  }

  List<String> getDailyReading(DateTime date) {
    final feasts = cal.getDayReadings(date);

    if (feasts.isNotEmpty) {
      // for these two feasts, there can be additional "special days", e.g. Sunday before Theophany or Sunday before Elevation of Cross
      if (date.weekday == DateTime.sunday && feasts[0].name == "circumcision" ||
          feasts[0].name == "nativityOfTheotokos") {
        return feasts.map((f) => f.reading!).toList();
      } else if (feasts.first.type == FeastType.great) {
        return List.from(rr[date] ?? [])
          ..addAll(feasts.filter((f) => f.type == FeastType.great).map((f) => f.reading!));
      } else {
        List<String> result = [];

        if (date.isBetween(cal.greatLentStart, cal.d("sunday1GreatLent") - 1.days)) {
          // only Lent reading during 1st week of Great Lent
          return rr[date] ?? [];
        } else if (date == cal.d("sundayOfZacchaeus") ||
            date == cal.d("sundayOfPublicianAndPharisee") ||
            date == cal.d("sundayOfProdigalSon") ||
            date == cal.d("sundayOfDreadJudgement") ||
            date == cal.d("cheesefareSunday")) {
          result = List.from(rr[date] ?? [])..addAll(feasts.map((f) => f.reading!));
        } else {
          result = List.from(feasts.map((f) => f.reading!))..addAll(rr[date] ?? []);
        }

        return result.take(2).toList();
      }
    } else {
      return rr[date] ?? [];
    }
  }

  static List<String> forDate(DateTime date) {
    if (!models.containsKey(date.year)) {
      models[date.year] = ChurchReading(date);
    }

    return models[date.year]!.getDailyReading(date);
  }
}
