import 'package:group_list_view/group_list_view.dart';
import 'package:ponomar/church_reading.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:supercharged/supercharged.dart';

import 'dart:async';

import 'book_model.dart';
import 'globals.dart';
import 'church_calendar.dart';
import 'pericope_model.dart';

class TypikaDateIterator implements Iterator<DateTime> {
  TypikaDateIterator(this.startDate) : currentDate = startDate - 1.days;

  final DateTime startDate;
  DateTime currentDate;

  @override
  DateTime get current => currentDate;

  @override
  bool moveNext() {
    do {
      currentDate = ChurchCalendar.nearestSundayAfter(currentDate);
    } while (Cal.getGreatFeast(currentDate).isNotEmpty);

    return true;
  }
}

class TypikaDate extends Iterable<DateTime> {
  TypikaDate(this.startDate);
  final DateTime startDate;

  @override
  Iterator<DateTime> get iterator => TypikaDateIterator(startDate);
}

class TypikaModel extends BookModel {
  @override
  late String code;

  @override
  BookContentType get contentType => BookContentType.html;

  @override
  late String title;

  @override
  String? get author => "";

  @override
  String lang;

  @override
  bool get hasChapters => false;

  @override
  late Future initFuture;

  @override
  late Iterable<DateTime>? dateIterator;

  @override
  set date(DateTime? d) {
    if (d != null) initFuture = setDate(d);
  }

  DateTime startDate;
  late ChurchCalendar cal;
  late int tone;
  late String reading;

  late Database db;
  late List<String> data;
  late List<String> prokimen;
  late List<String> fragments;

  TypikaModel(this.lang, this.startDate) {
    initFuture = loadBook();
  }

  Future loadBook() async {
    db = await DB.open("typika_$lang.sqlite");

    dateIterator = TypikaDate(startDate);

    code = "typika_$lang";
    title = (await loadString("title"))!;

    List<Map<String, Object?>> querySections =
    await db.query("content", columns: ["title"], orderBy: "section");

    data = List<String>.from(querySections.map<String>((e) => e["title"] as String));
  }

  Future setDate(DateTime date) async {
    cal = Cal.fromDate(date);
    tone = cal.getTone(date)!;

    List<Map<String, Object?>> queryFragments =
    await db.query("fragments", columns: ["text"], where: "glas=$tone", orderBy: "id");

    fragments = List<String>.from(queryFragments.map<String>((e) => e["text"] as String));

    List<Map<String, Object?>> queryProkimen =
    await db.query("prokimen", columns: ["text"], where: "glas=$tone", orderBy: "id");

    prokimen = List<String>.from(queryProkimen.map<String>((e) => e["text"] as String));

    prokimen.addAll(prokimen[0].split("/"));
    prokimen[0] = prokimen[0].replaceAll("/", " ");

    reading = ChurchReading.forDate(date).last;
  }

  Future<String?> loadString(String key) async =>
      SqfliteExt.firstStringValue(await db.query("data", columns: ["value"], where: "key='$key'"));

  @override
  List<String> getSections() => [""];

  @override
  List<String> getItems(int section) => data;

  @override
  String getTitle(BookPosition pos) => data[pos.index!.index];

  @override
  Future getContent(BookPosition pos) async {
    var content = SqfliteExt.firstStringValue(await db.query("content",
        columns: ["text"], where: "section=?", whereArgs: [pos.index!.index + 1])) as String;

    content = content.replaceAll("GLAS", "$tone");

    fragments.forEachIndexed((s, i) async {
      content = content.replaceAll("FRAGMENT${i + 1}!", s);
    });

    prokimen.forEachIndexed((s, i) async {
      content = content.replaceAll("PROKIMEN${i + 1}", s);
    });

    final pericope = PericopeModel(lang, reading);
    await pericope.initFuture;

    pericope.title.forEachIndexed((s, i) async {
      content = content.replaceAll("TITLE${i + 1}", s);
    });

    pericope.textContent.forEachIndexed((s, i) async {
      content = content.replaceAll("READING${i + 1}", s);
    });

    return content;
  }

  @override
  Future<String?> getComment(int commentId) async => SqfliteExt.firstStringValue(
      await db.query("comments", columns: ["text"], where: "id=?", whereArgs: [commentId]));

  @override
  Future<int> getNumChapters(IndexPath index) async =>
      Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(DISTINCT title) FROM content'))!;

  @override
  BookPosition? getNextSection(BookPosition pos) {
    final index = pos.index!;

    if (index.index < data.length - 1) {
      return BookPosition.modelIndex(
          this, IndexPath(section: index.section, index: index.index + 1));
    }

    return null;
  }

  @override
  BookPosition? getPrevSection(BookPosition pos) {
    final index = pos.index!;

    if (index.index > 0) {
      return BookPosition.modelIndex(
          this, IndexPath(section: index.section, index: index.index - 1));
    }

    return null;
  }
}
