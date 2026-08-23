import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:sqflite/sqflite.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supercharged/supercharged.dart';

import 'custom_list_tile.dart';
import 'globals.dart';
import 'church_day.dart';
import 'church_calendar.dart';
import 'epub_reader.dart';

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

    final cal = ChurchCalendar.fromDate(DateTime.utc(year, 1, 1));
    JSON.dateParser = cal.dateParser;

    days =
        query.map<ChurchDay>((e) => ChurchDay.fromJson(jsonDecode(e["text"] as String))).toList();

    final pascha = Cal.paschaDay(year);
    final pentecost = pascha + 49.days;
    final greatLentStart = pascha - 48.days;
    final isLeapYear = Cal.isLeap(year: year);

    day("findingOfHead").date = isLeapYear ? DateTime.utc(year, 3, 8) : DateTime.utc(year, 3, 9);
    day("holyFathersSixCouncils").date = Cal.nearestSunday(DateTime.utc(year, 7, 29));
    day("holyFathersSeventhCouncil").date = Cal.nearestSunday(DateTime.utc(year, 10, 24));

    day("saturdayOfFathers").date = greatLentStart - 2.days;
    day("sunday4GreatLent").date = greatLentStart + 27.days;

    day("greatMonday").date = pascha - 6.days;
    day("greatTuesday").date = pascha - 5.days;
    // day("greatWednesday").date = pascha - 4.days;
    day("greatSaturday").date = pascha - 1.days;

    day("ascension").date = pascha + 39.days;
    day("pentecost").date = pentecost;
    day("sunday1AfterPentecost").date = pentecost + 7.days;

    day("sunday3AfterPascha").date = pascha + 14.days;
    day("sunday4AfterPascha").date = pascha + 21.days;
    day("sunday7AfterPascha").date = pascha + 42.days;

    day("kurskTheotokos").date = pentecost + 12.days;
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
    final cc = ChurchCalendar.fromDate(date);
    DateTime d = date;

    await cal.initFuture;

    if (cc.isLeapYear && date.isBetween(cc.leapStart, cc.leapEnd - 1.days)) {
      d = date + 1.days;
    }

    final days = cal.days.where((e) => e.date == d).toList();
    if (days.isEmpty) return null;

    List<Widget> res = [];

    for (var d in days) {
      res.add(CustomListTile(
          padding: 10,
          title: d.comment!,
          subtitle: 'lives_of_saints'.tr(),
          onTap: () => openEpubAsset(d.reading!)));
    }

    return Column(children: res + [const SizedBox(height: 5)]);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Widget?>(
      future: fetch(context),
      builder: (BuildContext context, AsyncSnapshot<Widget?> snapshot) {
        final result = snapshot.data;
        return result ?? Container();
      });
}
