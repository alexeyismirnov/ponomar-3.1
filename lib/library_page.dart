import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'custom_list_tile.dart';
import 'calendar_appbar.dart';
import 'bible_model.dart';
import 'book_model.dart';
import 'globals.dart';
import 'book_toc.dart';
import 'ebook_model.dart';
import 'bookmarks_model.dart';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late DateTime date;
  late DateTime savedDate;

  late List<List<BookModel>> books;
  List<String> sections = [];
  bool ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    sections = ["library" "", "Bible"];

    books = [
      [BookmarksModel()],
      [
        OldTestamentModel("ru"),
        NewTestamentModel("ru"),
        OldTestamentModel("cs"),
        NewTestamentModel("cs")
      ]
    ];

    if (context.languageCode == "ru") {
      sections.add("Молитвослов");
      books.add([
        EbookModel("prayerbook.sqlite"),
        EbookModel("canons.sqlite"),
      ]);

      sections.add("Богослужение");
      books.add([
        EbookModel("vigil.sqlite"),
        EbookModel("liturgy.sqlite"),
      ]);

      sections.add("Разное");
      books.add([
        EbookModel("synaxarion.sqlite"),
        EbookModel("old_testament_overview.sqlite"),
        EbookModel("new_testament_overview.sqlite"),
        EbookModel("taushev.sqlite"),
        EbookModel("zerna.sqlite"),
        EbookModel("zvezdinsky.sqlite"),
      ]);
    }

    BookmarksModel.books = books.expand((b) => b).toList();

    var futures = <Future>[];
    for (final model in books.expand((e) => e)) {
      futures.add(model.initFuture);
    }

    Future.wait(futures).then((_) => setState(() => ready = true));
  }

  Widget getContent() {
    if (!ready) return Container();

    return GroupListView(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      sectionsCount: sections.length,
      countOfItemInSection: (int section) => books[section].length,
      itemBuilder: (BuildContext context, IndexPath index) {
        return CustomListTile(
          padding: 10,
          reversed: true,
          lang: books[index.section][index.index].lang,
          onTap: () => BookTOC(books[index.section][index.index]).push(context),
          title: books[index.section][index.index].title,
          subtitle: books[index.section][index.index].author ?? "",
        );
      },
      groupHeaderBuilder: (BuildContext context, int section) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(sections[section].tr().toUpperCase(), style: Theme.of(context).textTheme.labelLarge),
          const Divider(thickness: 1)
        ]);
      },
      separatorBuilder: (context, index) => const SizedBox(),
      sectionSeparatorBuilder: (context, section) => const SizedBox(height: 15),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
              [CalendarAppbar(title: "", showActions: false)],
          body: Padding(padding: const EdgeInsets.all(15), child: getContent())));
}
