import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:supercharged/supercharged.dart';

import 'church_calendar.dart';
import 'custom_list_tile.dart';
import 'book_page_single.dart';
import 'globals.dart';
import 'church_reading.dart';
import 'book_cell.dart';

class FeofanView extends StatelessWidget {
  static Database? db;

  final DateTime date;
  final Cal cal;
  final double fontSize;
  late String savedContent;

  FeofanView(this.date)
      : cal = Cal.fromDate(date),
        fontSize = ConfigParam.fontSize.val();

  CustomListTile getListTile(BuildContext context, String content,
      {String? subtitle, String title = "Мысли на каждый день"}) {
    savedContent = content;
    return CustomListTile(
        title: title,
        subtitle: subtitle,
        onTap: () => BookPageSingle(title, builder: () => BookCellText(content)).push(context));
  }

  Future<String?> getFeofan(String id) async {
    var data = await db!.query("thoughts", columns: ["descr"], where: "id=\"$id\"");
    return data.isEmpty ? null : data.first["descr"] as String;
  }

  Future<String?> getFeofanGospel(String id) async {
    var data = await db!.query("thoughts", columns: ["descr"], where: "id LIKE'%$id' AND fuzzy=1");
    return data.isEmpty ? null : data.first["descr"] as String;
  }

  String readingTranslate(String str) =>
      JSON.bibleTrans["ru"]!.entries.fold(str, (String prev, e) => prev.replaceAll(e.key, e.value));

  Future<List<Widget>> fetch(BuildContext context) async {
    List<CustomListTile> result = [];

    db ??= await DB.open("feofan.sqlite");

    if (date == cal.d("meetingOfLord")) {
      return [getListTile(context, (await getFeofan("33"))!)];
    } else if (date == DateTime.utc(cal.year, 9, 21) || date == DateTime.utc(cal.year, 10, 14)) {
      return [];
    } else if (date == DateTime.utc(cal.year, 12, 4)) {
      return [getListTile(context, (await getFeofan("325"))!)];
    } else if (date == DateTime.utc(cal.year, 8, 19)) {
      return [getListTile(context, (await getFeofan("218"))!)];
    } else if (date == cal.greatLentStart - 3.days) {
      return [getListTile(context, (await getFeofan("36"))!)];
    } else if (date == cal.greatLentStart - 5.days) {
      return [getListTile(context, (await getFeofan("34"))!)];
    } else if (date == cal.pascha - 3.days || date == cal.pascha - 2.days) {
      return [];
    } else if (date == cal.d("sundayBeforeNativity1") || date == cal.d("sundayBeforeNativity2")) {
      return [getListTile(context, (await getFeofan("346"))!)];
    } else if (date.isBetween(cal.greatLentStart, cal.pascha - 1.days)) {
      final num = (cal.greatLentStart >> date) + 39;
      return [getListTile(context, (await getFeofan("$num"))!)];
    } else {
      final readings = ChurchReading.forDate(date);

      for (final r in readings) {
        final pericope = readingTranslate(r.split("#")[0]);
        final id = pericope.replaceAll(" ", "");

        var f = await getFeofan(id);
        if (f != null) result.add(getListTile(context, f, subtitle: pericope));
      }

      if (result.isEmpty) {
        for (final r in readings) {
          final str = r.split("#")[0];
          final p = str.split(" ");

          for (final i in getRange(0, p.length, 2)) {
            if (["John", "Luke", "Mark", "Matthew"].contains(p[i])) {
              final pericope = readingTranslate(p[i] + " " + p[i + 1]);
              final id = pericope.replaceAll(" ", "");

              var f = await getFeofanGospel(id);
              if (f != null) result.add(getListTile(context, f, subtitle: pericope));
            }
          }
        }
      }

      if (result.length == 1) {
        return [getListTile(context, savedContent)];
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Widget>>(
      future: fetch(context),
      builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
        if (snapshot.hasData) {
          final result = List<Widget>.from(snapshot.data!);

          if (result.isNotEmpty) {
            return Column(children: result + <Widget>[const SizedBox(height: 5)]);
          }
        }

        return Container();
      });
}
