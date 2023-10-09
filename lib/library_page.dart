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
import 'yungerov.dart';
import 'bookmarks_model.dart';
import 'typica_model.dart';

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
    final lang = context.countryCode;

    if (ready) return;

    sections = ["library", "Bible"];

    books = [
      [BookmarksModel()],
    ];

    if (context.languageCode == "ru") {
      books.add([
        OldTestamentModel("ru"),
        NewTestamentModel("ru"),
        OldTestamentModel("cs"),
        NewTestamentModel("cs"),
        YungerovModel()
      ]);

      sections.add("Молитвослов");
      books.add([
        EbookModel("prayerbook_ru.sqlite"),
        EbookModel("canons.sqlite"),
      ]);

      sections.add("Богослужение");
      books.add([
        EbookModel("vigil_ru.sqlite"),
        EbookModel("liturgy_ru.sqlite"),
      ]);

      sections.add("Разное");
      books.add([
        EbookModel("synaxarion_ru.sqlite"),
        EbookModel("old_testament_overview.sqlite"),
        EbookModel("new_testament_overview.sqlite"),
        EbookModel("taushev.sqlite"),
        EbookModel("zerna.sqlite"),
        EbookModel("zvezdinsky.sqlite"),
      ]);
    } else {
      books.add([OldTestamentModel(lang), NewTestamentModel(lang)]);

      final today = DateTime.now();
      final today_utc = DateTime.utc(today.year, today.month, today.day);

      sections.add("liturgical_books".tr());
      books.add([
        EbookModel("vigil_$lang.sqlite"),
        EbookModel("liturgy_$lang.sqlite"),
        TypikaModel(lang, today_utc)
      ]);

      sections.add("other".tr());
      books.add([
        EbookModel("prayerbook_$lang.sqlite"),
        EbookModel("synaxarion_$lang.sqlite"),
        if (context.languageCode == "en") ...[EbookModel("augustin_en.sqlite")]
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
          onTap: () async {
            final model = books[index.section][index.index];
            if (model.dateIterator != null) {
              final df = DateFormat.yMMMMd(context.languageCode);

              final serviceDate = await AlertDialog(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      contentPadding: const EdgeInsets.all(5.0),
                      content: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: context.screenWidth * 0.5,
                                  minWidth: context.screenWidth * 0.5,
                                  maxHeight: 200),
                              child: ListView.builder(
                                  itemBuilder: (BuildContext _, int i) => ListTile(
                                      dense: true,
                                      onTap: () =>
                                          Navigator.pop(context, model.dateIterator!.elementAt(i)),
                                      title: Text(df.format(model.dateIterator!.elementAt(i)),
                                          style: Theme.of(context).textTheme.titleMedium))))))
                  .show(context);

              if (serviceDate != null) {
                model.date = serviceDate;
                Future.wait([model.initFuture]).then((_) => BookTOC(model).push(context));
              }
            } else {
              BookTOC(books[index.section][index.index]).push(context);
            }
          },
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
