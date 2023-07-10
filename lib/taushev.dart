import 'package:flutter/material.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'custom_list_tile.dart';
import 'book_page_single.dart';
import 'book_cell.dart';
import 'ebook_model.dart';
import 'globals.dart';

class TaushevView extends StatelessWidget {
  final String r;
  final author = "Архиеп. Аверкий (Таушев)";
  final model = EbookModel("taushev.sqlite");

  TaushevView(this.r);

  Future<List<Map<String, Object?>>> getData(String id) => model.db
      .query("content", columns: ["subtitle", "text"], where: "id=\"$id\"");

  Future<Widget?> fetch(BuildContext context) async {
    await model.initFuture;

    final str = r.split("#")[0];
    final p = str.trim().split(" ");

    for (final i in getRange(0, p.length, 2)) {
      if (["John", "Luke", "Mark", "Matthew"].contains(p[i])) {
        final id = JSON.translateReading("${p[i]} ${p[i + 1]}",
            lang: context.countryCode);

        final data = (await getData(id))[0];

        return CustomListTile(
            title: data["subtitle"] as String,
            subtitle: author,
            onTap: () => BookPageSingle(id,
                    builder: () => BookCellText(data["text"] as String))
                .push(context));
      }
    }

    return null;
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
