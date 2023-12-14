import 'package:group_list_view/group_list_view.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'dart:async';

import 'book_model.dart';
import 'globals.dart';

class EbookModel extends BookModel {
  @override
  late String code;

  @override
  late BookContentType contentType;

  @override
  late String title;

  @override
  late String? author;

  @override
  late String lang;

  @override
  bool get hasChapters => false;

  @override
  late Future initFuture;

  late Database db;
  late List<String> sections;
  late Map<int, List<String>> items = {};

  EbookModel(String filename) {
    initFuture = loadBook(filename);
  }

  Future loadBook(String filename) async {
    List<Map<String, Object?>> queryItems = [];

    db = await DB.open(filename);

    code = (await loadString("code"))!;
    title = (await loadString("title"))!;
    author = (await loadString("author"));
    lang = (await loadString("lang")) ?? "en";

    contentType = BookContentType.values[Sqflite.firstIntValue(
        await db.query("data", columns: ["value"], where: "key='contentType'"))!];

    List<Map<String, Object?>> querySections =
        await db.query("sections", columns: ["title"], orderBy: "id");

    sections = querySections.map<String>((e) => e["title"] as String).toList();

    for (final (i, _) in sections.indexed) {
      queryItems = await db.query("content",
          columns: ["title"], where: "section=?", whereArgs: [i], orderBy: "item");

      items[i] = queryItems.map<String>((e) => e["title"] as String).toList();
    }
  }

  Future<String?> loadString(String key) async =>
      SqfliteExt.firstStringValue(await db.query("data", columns: ["value"], where: "key='$key'"));

  @override
  List<String> getSections() {
    return sections;
  }

  @override
  List<String> getItems(int section) {
    return items[section]!;
  }

  @override
  String getTitle(BookPosition pos) => items[pos.index!.section]![pos.index!.index];

  @override
  Future getContent(BookPosition pos) async => SqfliteExt.firstStringValue(await db.query("content",
      columns: ["text"],
      where: "section=? AND item=?",
      whereArgs: [pos.index!.section, pos.index!.index]));

  @override
  Future<String?> getComment(int commentId) async => SqfliteExt.firstStringValue(
      await db.query("comments", columns: ["text"], where: "id=?", whereArgs: [commentId]));

  @override
  Future<int> getNumChapters(IndexPath index) async =>
      Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(DISTINCT title) FROM content'))!;

  @override
  BookPosition? getNextSection(BookPosition pos) {
    final index = pos.index!;
    final sections = getSections();
    final items = getItems(index.section);

    if (index.index + 1 == items.length) {
      if (index.section + 1 == sections.length) {
        return null;
      } else {
        return BookPosition.modelIndex(this, IndexPath(section: index.section + 1, index: 0));
      }
    } else {
      return BookPosition.modelIndex(
          this, IndexPath(section: index.section, index: index.index + 1));
    }
  }

  @override
  BookPosition? getPrevSection(BookPosition pos) {
    final index = pos.index!;

    if (index.index == 0) {
      if (index.section == 0) {
        return null;
      } else {
        final items = getItems(index.section - 1);

        return BookPosition.modelIndex(
            this, IndexPath(section: index.section - 1, index: items.length - 1));
      }
    } else {
      return BookPosition.modelIndex(
          this, IndexPath(section: index.section, index: index.index - 1));
    }
  }

  @override
  String? getBookmark(BookPosition pos) {
    final index = pos.index!;
    return "${code}_${index.section}_${index.index}";
  }

  @override
  String getBookmarkName(String bookmark) {
    final comp = bookmark.split("_");
    if (comp[0] != code) return "";

    final section = int.parse(comp[1]);
    final row = int.parse(comp[2]);

    final item_title = items[section]![row];
    return "$title — $item_title";
  }
}
