import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:supercharged/supercharged.dart';

import 'globals.dart';
import 'church_day.dart';
import 'church_calendar.dart';

class SaintModel {
  String lang;
  static Map<String, Database> databases = {};

  SaintModel(this.lang);

  Future prepare() async {
    List<String> filenames = List<int>.generate(12, (i) => i + 1)
        .map((i) => "saints_%02d_$lang.sqlite".format([i]))
        .toList();

    filenames.forEach((f) async {
      await DB.prepare(basename: "assets/saints", filename: f);
    });
  }

  Future<List<Saint>> fetch(DateTime d) async {
    List<Saint> saints = [];
    var cal = Cal.fromDate(d);

    if (cal.isLeapYear) {
      if (d.isBetween(cal.leapStart, cal.leapEnd - 1.days)) {
        saints = await _saintData(d + 1.days);
      } else if (d == cal.leapEnd) {
        saints = await _saintData(DateTime.utc(cal.year, 2, 29));
      } else {
        saints = await _saintData(d);
      }
    } else {
      saints = await _saintData(d);
      if (d == cal.leapEnd) {
        saints.addAll(await _saintData(DateTime.utc(2000, 2, 29)));
      }
    }

    return saints;
  }

  Future<List<Saint>> _saintData(DateTime d) async {
    var filename = "saints_%02d_$lang.sqlite".format([d.month]);
    List<Saint> saints = [];

    if (!databases.containsKey(filename)) {
      databases[filename] = await DB.open(filename);
    }

    List<Map<String, Object?>> data = await databases[filename]!
        .query("saints", columns: ["name", "typikon"], orderBy: "-typikon", where: "day=${d.day}");

    for (final Map<String, Object?> row in data) {
      saints.add(Saint(row["name"] as String, FeastType.values[row["typikon"] as int]));
    }

    return saints;
  }
}
