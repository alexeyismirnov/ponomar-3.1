import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:sqflite/sqflite.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'package:supercharged/supercharged.dart';

import 'custom_list_tile.dart';
import 'globals.dart';
import 'church_day.dart';
import 'church_calendar.dart';

class SaintsCalendar {
  int year;
  String lang;
  List<ChurchDay> days = [];
  late Future initFuture;
  late Database db;

  static Map<String, SaintsCalendar> calendars = {};

  SaintsCalendar._(this.year, this.lang) {
    initFuture = loadBook();
  }

  ChurchDay day(String name) => days.where((e) => e.name == name).first;

  Future loadBook() async {
    final filename = "augustin_$lang.sqlite";
    db = await DB.open(filename);

    List<Map<String, Object?>> query =
        await db.query("content", columns: ["text"], orderBy: "title");

    days =
        query.map<ChurchDay>((e) => ChurchDay.fromJson(jsonDecode(e["text"] as String))).toList();

    final pascha = Cal.paschaDay(year);
    day("pentecost").date = pascha + 49.days;
  }

  factory SaintsCalendar.fromDate(DateTime d, {required String lang}) {
    var year = d.year;

    if (!SaintsCalendar.calendars.containsKey("$year-$lang")) {
      SaintsCalendar.calendars["$year-$lang"] = SaintsCalendar._(year, lang);
    }

    return SaintsCalendar.calendars["$year-$lang"]!;
  }
}

class SaintsLivesView extends StatelessWidget {
  final DateTime date;
  SaintsLivesView(this.date);

  Future<Widget?> fetch(BuildContext context) async {
    final cal = SaintsCalendar.fromDate(date, lang: context.countryCode);
    await cal.initFuture;

    final d = cal.days.where((e) => e.date == date);
    if (d.isEmpty) return null;

    return CustomListTile(
        title: d.first.comment!,
        subtitle: 'lives_of_saints'.tr(),
        onTap: () => VocsyEpub.openAsset('assets/epubs/${d.first.reading}'));
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Widget?>(
      future: fetch(context),
      builder: (BuildContext context, AsyncSnapshot<Widget?> snapshot) {
        final result = snapshot.data;

        if (result != null) {
          return Column(children: [result, const SizedBox(height: 5)]);
        }

        return Container();
      });
}
