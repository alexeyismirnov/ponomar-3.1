import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:supercharged/supercharged.dart';

import 'church_calendar.dart';
import 'custom_list_tile.dart';
import 'troparion_view.dart';

class Troparion {
  String title = "";
  String content = "";
  String? glas;
  String? url;

  Troparion.fromMap(Map<String, Object?> data) {
    title = data["title"] as String;
    content = data["content"] as String;
    glas = data["glas"] as String?;
    url = data["url"] as String?;
  }
}

class SaintTroparion extends StatelessWidget {
  static Database? db;

  final DateTime date;
  final Cal cal;

  SaintTroparion(this.date) : cal = Cal.fromDate(date);

  Future<List<Troparion>> fetch() async {
    List<Troparion> saints = [];

    if (cal.isLeapYear) {
      if (date.isBetween(cal.leapStart, cal.leapEnd - 1.days)) {
        saints = await _saintData(date + 1.days);
      } else if (date == cal.leapEnd) {
        saints = await _saintData(DateTime.utc(cal.year, 2, 29));
      } else {
        saints = await _saintData(date);
      }
    } else {
      saints = await _saintData(date);
      if (date == cal.leapEnd) {
        saints.addAll(await _saintData(DateTime.utc(2000, 2, 29)));
      }
    }

    return saints;
  }

  Future<List<Troparion>> _saintData(DateTime d) async {
    List<Troparion> result = [];

    db ??= await DB.open("troparion.sqlite");

    List<Map<String, Object?>> data = await db!.query("tropari",
        columns: ["title", "glas", "content"], where: "day=${d.day} AND month=${d.month}");

    for (final Map<String, Object?> row in data) {
      result.add(Troparion.fromMap(row));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Troparion>>(
      future: fetch(),
      builder: (BuildContext context, AsyncSnapshot<List<Troparion>> snapshot) {
        if (snapshot.hasData) {
          final troparia = List<Troparion>.from(snapshot.data!);

          if (troparia.isNotEmpty) {
            return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: CustomListTile(
                    title: "Тропари и кондаки святым",
                    onTap: () => TroparionView(troparia).push(context)));
          }
        }

        return Container();
      });
}
