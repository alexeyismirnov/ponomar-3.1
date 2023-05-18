import 'package:flutter/material.dart';
import 'package:ponomar/book_model.dart';

import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:group_list_view/group_list_view.dart';

import 'custom_list_tile.dart';
import 'book_page_single.dart';
import 'book_cell.dart';
import 'ebook_model.dart';
import 'globals.dart';

class ZernaView extends StatelessWidget {
  final DateTime date;
  ZernaView(this.date);

  Future<Widget?> fetch(BuildContext context) async {
    final model = EbookModel("zerna.sqlite");
    await model.initFuture;

    final startDate = DateTime.utc(date.year, 1, 1);
    final numChapters = await model.getNumChapters(IndexPath(section: 0, index: 0));

    final index = (startDate >> date) % numChapters;

    final pos = BookPosition.index(IndexPath(section: 0, index: index));
    final title = await model.getTitle(pos);
    final text = await model.getContent(pos);

    final content = BookCellText(text);

    return CustomListTile(
        title: model.title,
        subtitle: title,
        onTap: () => BookPageSingle(title, builder: () => content).push(context));
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
