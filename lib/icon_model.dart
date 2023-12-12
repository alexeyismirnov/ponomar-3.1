import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:supercharged/supercharged.dart';

import 'church_day.dart';
import 'church_calendar.dart';

class SaintIcon {
  final int id;
  final String name;
  final bool has_icon;

  SaintIcon(this.id, this.name, this.has_icon);
}

class IconModel {
  static late Database db;

  static Future prepare() async {
    await DB.prepare(path: "assets/icons/icons.sqlite");
    db = await DB.open("icons.sqlite");
  }

  static Future<List<SaintIcon>> fetch(DateTime d) async {
    List<SaintIcon> saints = [];
    final cal = ChurchCalendar.fromDate(d);

    List<ChurchDay> movable = [
      ChurchDay("100001", FeastType.great, date: cal.d("palmSunday"), comment: "palmSunday"),
      ChurchDay("100000", FeastType.great, date: cal.pascha, comment: "pascha"),
      ChurchDay("100002", FeastType.great, date: cal.d("ascension"), comment: "ascension"),
      ChurchDay("100003", FeastType.great, date: cal.pentecost, comment: "pentecost"),
      ChurchDay("2250", FeastType.none, date: cal.pascha + 2.days, comment: "theotokosIveron"),
      ChurchDay("100100", FeastType.none,
          date: cal.pascha + 5.days, comment: "theotokosLiveGiving"),
      ChurchDay("100101", FeastType.none,
          date: cal.pascha + 24.days, comment: "theotokosDubenskaya"),
      ChurchDay("100103", FeastType.none,
          date: cal.pascha + 42.days, comment: "theotokosChelnskaya"),
      ChurchDay("100105", FeastType.none, date: cal.pascha + 56.days, comment: "theotokosWall"),
      ChurchDay("100106", FeastType.none,
          date: cal.pascha + 56.days, comment: "theotokosSevenArrows"),
      ChurchDay("100108", FeastType.none, date: cal.pascha + 61.days, comment: "theotokosTabynsk"),
    ];

    final codes = movable.where((e) => e.date == d).toList();

    for (final code in codes) {
      List<Map<String, Object?>> data = await db.query("app_saint",
          columns: ["id", "name", "has_icon"], where: "id=${code.name}");

      for (final Map<String, Object?> row in data) {
        saints
            .add(SaintIcon(row["id"] as int, row["name"] as String, (row["has_icon"] as int) == 1));
      }
    }

    if (cal.isLeapYear) {
      if (d.isBetween(cal.leapStart, cal.leapEnd - 1.days)) {
        saints.addAll(await _addSaints(d + 1.days));
      } else if (d == cal.leapEnd) {
        saints.addAll(await _addSaints(DateTime.utc(cal.year, 2, 29)));
      } else {
        saints.addAll(await _addSaints(d));
      }
    } else {
      saints.addAll(await _addSaints(d));
      if (d == cal.leapEnd) {
        saints.addAll(await _addSaints(DateTime.utc(2000, 2, 29)));
      }
    }

    return saints;
  }

  static Future<List<SaintIcon>> _addSaints(DateTime d) async {
    List<SaintIcon> saints = [];
    final day = d.day;
    final month = d.month;

    List<Map<String, Object?>> data = await db.query("app_saint",
        columns: ["id", "name", "has_icon"], where: "month=$month AND day=$day AND has_icon=1");

    for (final Map<String, Object?> row in data) {
      saints.add(SaintIcon(row["id"] as int, row["name"] as String, (row["has_icon"] as int) == 1));
    }

    List<Map<String, Object?>> links = await db.query("app_saint JOIN link_saint",
        columns: [
          "link_saint.name AS name",
          "app_saint.id AS id",
          "app_saint.has_icon AS has_icon"
        ],
        where:
            "link_saint.month=$month AND link_saint.day=$day AND app_saint.id = link_saint.id AND app_saint.has_icon=1");

    for (final Map<String, Object?> row in links) {
      saints.add(SaintIcon(row["id"] as int, row["name"] as String, (row["has_icon"] as int) == 1));
    }

    return saints;
  }
}
