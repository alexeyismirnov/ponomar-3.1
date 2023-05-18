import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:supercharged/supercharged.dart';

import 'dart:io';

import 'church_calendar.dart';
import 'custom_list_tile.dart';
import 'file_download.dart';
import 'globals.dart';
import 'troparion_view.dart';
import 'troparion_model.dart';

class TroparionOfDay extends StatefulWidget {
  final DateTime date;
  TroparionOfDay(this.date);

  @override
  TroparionOfDayState createState() => TroparionOfDayState();
}

class TroparionOfDayState extends State<TroparionOfDay> {
  DateTime get date => widget.date;
  late Cal cal;

  static Database? db;

  @override
  void initState() {
    super.initState();
    cal = Cal.fromDate(date);
  }

  bool isAvailable() {
    if (date.isBetween(cal.d("palmSunday"), cal.pascha)) {
      return false;
    } else {
      return Cal.getGreatFeast(date).isEmpty;
    }
  }

  Future<List<Troparion>> fetch() async {
    int code;
    List<Troparion> result = [];

    db ??= await DB.open("tropari_day.sqlite", dirname: "${GlobalPath.documents}/tropari_day");

    if (date.isBetween(cal.pascha, cal.d("sunday2AfterPascha") - 1.days)) {
      code = 100;
    } else if (date.weekday == DateTime.sunday) {
      code = 10 + cal.getTone(date)!;
    } else {
      code = (date.weekday % 7) + 1;
    }

    List<Map<String, Object?>> data =
        await db!.query("tropari", columns: ["title", "url", "content"], where: "code=$code");

    for (final Map<String, Object?> row in data) {
      var rr = Map<String, Object?>.from(row);
      final url = rr["url"];
      if (url != null) rr["url"] = "${GlobalPath.documents}/tropari_day/$url.mp3";

      result.add(Troparion.fromMap(rr));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (!isAvailable()) return Container();

    String title;

    if (date.isBetween(cal.pascha, cal.d("sunday2AfterPascha") - 1.days)) {
      title = "Часы пасхальные";
    } else {
      title = "Тропарь и кондак дня";
    }

    if (File("${GlobalPath.documents}/tropari_day/tropari_day.sqlite").existsSync()) {
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
              onTap: () => FileDownload("$pCloudURL/prayerbook/tropari_day.zip")
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
