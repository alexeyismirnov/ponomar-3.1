import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'dart:io';

import 'church_calendar.dart';
import 'custom_list_tile.dart';
import 'file_download.dart';
import 'globals.dart';
import 'troparion_view.dart';
import 'troparion_model.dart';

class TroparionOfFeast extends StatefulWidget {
  final DateTime date;
  TroparionOfFeast(this.date);

  @override
  TroparionOfFeastState createState() => TroparionOfFeastState();
}

class TroparionOfFeastState extends State<TroparionOfFeast> {
  DateTime get date => widget.date;
  late Cal cal;

  static Database? db;

  @override
  void initState() {
    super.initState();
    cal = Cal.fromDate(date);
  }

  bool isAvailable() => Cal.getGreatFeast(date).isNotEmpty;

  Future<List<Troparion>> fetch() async {
    List<Troparion> result = [];

    db ??= await DB.open("tropari.sqlite", dirname: "${GlobalPath.documents}/tropari");

    final Map<String, int> codes = {
      "pascha": 1,
      "pentecost": 2,
      "ascension": 3,
      "palmSunday": 4,
      "nativityOfGod": 6,
      "circumcision": 7,
      "theophany": 9,
      "meetingOfLord": 10,
      "annunciation": 11,
      "nativityOfJohn": 12,
      "peterAndPaul": 13,
      "transfiguration": 14,
      "dormition": 15,
      "beheadingOfJohn": 16,
      "nativityOfTheotokos": 17,
      "exaltationOfCross": 18,
      "veilOfTheotokos": 19,
      "entryIntoTemple": 20
    };

    for (final f in Cal.getGreatFeast(date)) {
      final code = codes[f.name]!;

      List<Map<String, Object?>> data =
          await db!.query("tropari", columns: ["title", "url", "content"], where: "code=$code");

      for (final Map<String, Object?> row in data) {
        var rr = Map<String, Object?>.from(row);
        final url = rr["url"];
        if (url != null) rr["url"] = "${GlobalPath.documents}/tropari/$url.mp3";

        result.add(Troparion.fromMap(rr));
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (!isAvailable()) return Container();

    String title = "Тропарь и кондак праздника";

    if (File("${GlobalPath.documents}/tropari/tropari.sqlite").existsSync()) {
      return FutureBuilder<List<Troparion>>(
          future: fetch(),
          builder: (BuildContext context, AsyncSnapshot<List<Troparion>> snapshot) => (snapshot
                  .hasData)
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: CustomListTile(
                      title: title,
                      onTap: () =>
                          TroparionView(List<Troparion>.from(snapshot.data!), showActions: false)
                              .push(context)))
              : Container());
    } else {
      return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: CustomListTile(
              title: title,
              onTap: () => FileDownload("$pCloudURL/prayerbook/tropari.zip")
                      .show(context, canDismiss: false)
                      .then((dynamic res) => res ? fetch() : Future.value(null))
                      .then((dynamic res) {
                    if (res is List<Troparion>) {
                      setState(() {});
                      TroparionView(List<Troparion>.from(res), showActions: false).push(context);
                    }
                  })));
    }
  }
}
