import 'package:flutter/material.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supercharged/supercharged.dart';

import 'custom_list_tile.dart';
import 'troparion_view.dart';
import 'globals.dart';
import 'church_calendar.dart';

class Troparion {
  String title = "";
  String content = "";
  String? glas;

  Troparion.fromMap(Map<String, Object?> data) {
    title = data["title"] as String;
    content = data["content"] as String;
    glas = data["comment"] as String?;
  }
}

class TroparionWidget extends StatelessWidget {
  final DateTime date;
  final Cal cal;
  static Database? dbFeasts, dbSaints;

  TroparionWidget(this.date) : cal = Cal.fromDate(date);

  Future<List<Troparion>> getDataFeast(String id) async {
    List<Troparion> result = [];

    dbFeasts ??= await DB.open("troparion_feast_en.sqlite");

    List<Map<String, Object?>> data =
        await dbFeasts!.query("tropari", columns: ["title", "content"], where: "comment=\"$id\"");

    for (final Map<String, Object?> row in data) {
      result.add(Troparion.fromMap(row));
    }

    return result;
  }

  Future<List<Troparion>> getDataSaints(DateTime date) async {
    List<Troparion> result = [];

    dbSaints ??= await DB.open("troparion_en.sqlite");
    final d = date - 13.days;

    List<Map<String, Object?>> data = await dbSaints!.query("tropari",
        columns: ["title", "comment", "content"], where: "day=${d.day} AND month=${d.month}");

    for (final Map<String, Object?> row in data) {
      result.add(Troparion.fromMap(row));
    }

    if (cal.isLeapYear && date == cal.leapEnd) {
      List<Map<String, Object?>> data = await dbSaints!
          .query("tropari", columns: ["title", "comment", "content"], where: "day=29 AND month=2");

      for (final Map<String, Object?> row in data) {
        result.add(Troparion.fromMap(row));
      }
    }

    return result;
  }

  Future<List<Troparion>> fetchSunday(String lang) async {
    List<Troparion> results = [];

    if (date.weekday == DateTime.sunday) {
      final tone = cal.getTone(date);
      if (tone != null) {
        results.addAll(await getDataFeast("sundayGlas$tone"));
      }
    }
    return results;
  }

  Future<List<Troparion>> fetchFeast(String lang) async {
    List<Troparion> results = [];
    var feastsCodes = [
      "sundayOfPublicianAndPharisee",
      "sundayOfProdigalSon",
      "sundayOfDreadJudgement",
      "cheesefareSunday",
      "sunday1GreatLent",
      "sunday2GreatLent",
      "sunday3GreatLent",
      "sunday4GreatLent",
      "sunday5GreatLent",
      "sunday2AfterPascha",
      "sunday3AfterPascha",
      "sunday4AfterPascha",
      "sunday5AfterPascha",
      "sunday6AfterPascha",
      "sunday7AfterPascha",
      "sunday1AfterPentecost",
      "holyFathersSixCouncils",
      "holyFathersSeventhCouncil",
      "eveOfTheophany",
      "eveOfNativityOfGod",
      "saturday1GreatLent",
      "saturday2GreatLent",
      "saturday3GreatLent",
      "saturday4GreatLent",
      "saturday5GreatLent",
      "greatMonday",
      "greatTuesday",
      "greatWednesday",
      "greatThursday",
      "greatFriday",
      "greatSaturday"
    ];

    if (lang == "ru") {
      feastsCodes.add("midPentecost");
    }

    final descr = cal.getDayDescription(date).map<String>((f) => f.name);
    final feasts = feastsCodes.toSet().intersection(descr.toSet());

    for (final feast in feasts) {
      results.addAll(await getDataFeast(feast));
    }

    return results;
  }

  Future<List<Troparion>> fetch(String lang) async {
    List<Troparion> results = [];
    var greatFeasts = Cal.getGreatFeast(date);

    try {
      if (greatFeasts.isNotEmpty) {
        for (final feast in greatFeasts) {
          results.addAll(await getDataFeast(feast.name));

          final otherGreatFeasts = [
            "veilOfTheotokos",
            "nativityOfJohn",
            "beheadingOfJohn",
            "peterAndPaul",
            "dormition",
            "nativityOfTheotokos",
            "annunciation",
            "entryIntoTemple"
          ];

          if (otherGreatFeasts.contains(feast.name) && date.weekday == DateTime.sunday) {
            results.addAll(await fetchSunday(lang));
            results.addAll(await fetchFeast(lang));
          }
        }
      } else {
        results.addAll(await fetchSunday(lang));
        results.addAll(await fetchFeast(lang));
        results.addAll(await getDataSaints(date));
      }
    } catch (e) {
      print(e);
    }

    return results;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Troparion>>(
      future: fetch(context.languageCode),
      builder: (BuildContext context, AsyncSnapshot<List<Troparion>> snapshot) {
        if (snapshot.hasData) {
          final troparia = List<Troparion>.from(snapshot.data!);

          if (troparia.isNotEmpty) {
            return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: CustomListTile(
                    title: "troparia_kontakia".tr(),
                    onTap: () => TroparionView(troparia).push(context)));
          }
        }

        return Container();
      });
}
