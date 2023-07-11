import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'dart:async';

import 'book_model.dart';
import 'ebook_model.dart';

class YungerovModel extends EbookModel {
  YungerovModel() : super("yungerov.sqlite");

  @override
  Future getContent(BookPosition pos) async {
    final index = pos.index!;
    final ps = int.parse(items[index.section]![index.index].replaceAll(RegExp(r"\D"), ""));

    var result = "";

    final verses_yu =
        await db.query("content_yu", columns: ["text"], where: "psalm=?", whereArgs: [ps]);

    final verses_cs =
        await db.query("content_cs", columns: ["text"], where: "psalm=?", whereArgs: [ps]);

    verses_yu.forEachIndexed((text, index) {
      if (index > 0) {
        result += "<span class='rubric'>$index</span>&nbsp;";
      }

      result += "${text["text"]}<br/><span class='subtitle'>${verses_cs[index]["text"]}</span><p>";
    });

    return result;
  }
}
