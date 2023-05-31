import 'package:flutter/material.dart';

import 'package:group_list_view/group_list_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'dart:async';
import 'dart:convert';

import 'book_model.dart';
import 'globals.dart';

class BibleVerse {
  final int verse;
  final String text;

  BibleVerse(this.verse, this.text);
}

class BibleUtil {
  List<BibleVerse> content = [];
  String bookName = "";
  late String lang;

  BibleUtil();

  BibleUtil.fromMap(this.bookName, this.lang, List<Map<String, Object?>> data) {
    for (final Map<String, Object?> d in data) {
      content.add(BibleVerse(d["verse"] as int, d["text"] as String));
    }
  }

  static Future<BibleUtil> fetch(String bookName, String lang, String whereExpr) async {
    var db = await DB.open(bookName + "_$lang.sqlite");

    List<Map<String, Object?>> result =
        await db.query("scripture", columns: ["verse", "text"], where: whereExpr, orderBy: "verse");

    return BibleUtil.fromMap(bookName, lang, result);
  }

  String getText() {
    return content.map((line) => line.text).join("\n");
  }

  List<TextSpan> getTextSpan(BuildContext context) {
    double fontSize = ConfigParam.fontSize.val();
    String family =  Theme.of(context).textTheme.bodyLarge!.fontFamily!;
    List<TextSpan> result = [];

    if (lang == "cs") {
      fontSize += 3.0;
      family = "Ponomar";
    }

    final isPsalm =
        (bookName == "ps" && (context.languageCode == 'en' || context.languageCode == 'ru'));

    for (var line in content) {
      var verseId = isPsalm ? "\n${line.verse}. " : "${line.verse} ";

      result.add(TextSpan(
          text: verseId,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.red, fontSize: fontSize, fontFamily: family)));

      if (isPsalm) {
        int idx = line.text.indexOf(".");

        result.add(TextSpan(
            text: "${line.text.substring(0, idx)}\n",
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.red, fontSize: fontSize, fontFamily: family)));

        result.add(TextSpan(
            text: "${line.text.substring(idx + 2)}\n",
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontSize: fontSize, fontFamily: family)));
      } else {
        result.add(TextSpan(
            text: "${line.text}\n",
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontSize: fontSize, fontFamily: family)));
      }
    }

    return result;
  }
}

mixin BibleModel on BookModel {
  List<List<String>> get items;
  List<List<String>> get filenames;
  Map<IndexPath, int> numChaptersCache = {};

  @override
  Future prepare() async {
    filenames.expand((e) => e).forEach((f) async {
      await DB.prepare(basename: "assets/bible", filename: "${f}_$lang.sqlite");
    });
  }

  @override
  Future<int> getNumChapters(IndexPath index) async {
    final bookName = filenames[index.section][index.index];
    var db = await DB.open("${bookName}_$lang.sqlite");

    int result =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(DISTINCT chapter) FROM scripture'))!;

    numChaptersCache[index] = result;

    return result;
  }

  @override
  List<String> getItems(int section) {
    return items[section].map((s) => s.tr(gender: lang)).toList();
  }

  @override
  Future<String> getTitle(BookPosition pos) {
    String? s;
    var index = pos.index;
    var chapter = pos.chapter;

    if (index == null || chapter == null) {
      return Future<String>.value("");
    } else if (filenames[index.section][index.index] == "ps") {
      s = "Kathisma %d".tr();
    } else {
      s = "Chapter %d".tr();
    }

    return Future<String>.value(s.format([chapter + 1]));
  }

  @override
  Future getContent(BookPosition pos) async {
    var index = pos.index;
    var chapter = pos.chapter;

    if (index == null || chapter == null) {
      return Future<String?>.value(null);
    }

    final bookName = filenames[index.section][index.index];

    var result = await BibleUtil.fetch(bookName, lang, "chapter=${chapter + 1}");
    return result;
  }

  @override
  BookPosition? getNextSection(BookPosition pos) {
    final index = pos.index!;
    final chapter = pos.chapter!;
    final numChapters = numChaptersCache[index] ?? 0;

    return (chapter < numChapters - 1)
        ? BookPosition.modelIndex(this, index, chapter: chapter + 1)
        : null;
  }

  @override
  BookPosition? getPrevSection(BookPosition pos) {
    final index = pos.index!;
    final chapter = pos.chapter!;

    return (chapter > 0) ? BookPosition.modelIndex(this, index, chapter: chapter - 1) : null;
  }

  @override
  String? getBookmark(BookPosition pos) {
    final index = pos.index!;
    final chapter = pos.chapter!;
    return "${code}_${index.section}_${index.index}_$chapter";
  }

  @override
  String getBookmarkName(String bookmark) {
    final comp = bookmark.split("_");
    if (comp[0] != code) return "";

    final section = int.parse(comp[1]);
    final row = int.parse(comp[2]);
    final chapter = int.parse(comp[3]);

    final header = (filenames[section][row] == "ps") ? "Kathisma %d".tr() : "Chapter %d".tr();
    final chapterTitle = header.format([chapter + 1]);

    return "$title - ${items[section][row].tr()}, $chapterTitle";
  }
}

class OldTestamentModel extends BookModel with BibleModel {
  @override
  final items =
      jsonDecode(JSON.OldTestamentItems).map<List<String>>((l) => List<String>.from(l)).toList();

  @override
  final filenames = jsonDecode(JSON.OldTestamentFilenames)
      .map<List<String>>((l) => List<String>.from(l))
      .toList();

  @override
  String get code => lang == "cs" ? "OldTestamentCS" : "OldTestament";

  @override
  BookContentType get contentType => BookContentType.text;

  @override
  String get title => "Old Testament".tr(gender: lang);

  @override
  String? author;

  @override
  String lang;

  @override
  bool get hasChapters => true;

  @override
  Future get initFuture => Future.value(null);

  OldTestamentModel(this.lang);

  @override
  List<String> getSections() {
    return ["Five Books of Moses", "Historical books", "Wisdom books", "Prophets books"]
        .map((s) => s.tr(gender: lang))
        .toList();
  }
}

class NewTestamentModel extends BookModel with BibleModel {
  @override
  final items =
      jsonDecode(JSON.NewTestamentItems).map<List<String>>((l) => List<String>.from(l)).toList();

  @override
  final filenames = jsonDecode(JSON.NewTestamentFilenames)
      .map<List<String>>((l) => List<String>.from(l))
      .toList();

  @override
  String get code => lang == "cs" ? "NewTestamentCS" : "NewTestament";

  @override
  BookContentType get contentType => BookContentType.text;

  @override
  String get title => "New Testament".tr(gender: lang);

  @override
  String? author;

  @override
  String lang;

  @override
  bool get hasChapters => true;

  @override
  Future get initFuture => Future.value(null);

  NewTestamentModel(this.lang);

  @override
  List<String> getSections() {
    return ["Four Gospels and Acts", "Catholic Epistles", "Epistles of Paul", "Apocalypse"]
        .map((s) => s.tr(gender: lang))
        .toList();
  }
}
