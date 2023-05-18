import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

class StoryModel {
  late Database db;
  late Future initFuture;
  String filename;

  StoryModel(this.filename) {
    initFuture = initDB(filename);
  }

  Future initDB(String filename) async {
    db = await DB.open(filename);
    return db;
  }

  Future<String> getImage(String id) async {
    List<Map<String, dynamic>> snapshot = await db.rawQuery('SELECT image FROM icons WHERE id="$id"');
    return snapshot.isEmpty ? Future.value('') : Future.value(snapshot.first.values.first ?? '');
  }

  Future<String> getData(String key) async {
    List<Map<String, dynamic>> snapshot =
        await db.rawQuery('SELECT value FROM data WHERE key="$key"');

    return snapshot.first.values.first;
  }

  Future<int> getPageCount() async {
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM icons'))!;
  }

  Future<List<dynamic>> getContent(String id, String lang) {
    return db.rawQuery('SELECT text FROM content WHERE id="$id" AND lang="$lang" ORDER BY line');
  }
}
