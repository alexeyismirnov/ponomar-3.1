import 'package:flutter/material.dart';

import 'package:group_list_view/group_list_view.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:easy_localization/easy_localization.dart';

import 'calendar_appbar.dart';
import 'book_model.dart';
import 'globals.dart';
import 'book_page_multiple.dart';
import 'bookmarks_model.dart';
import 'bible_model.dart';

class _ChaptersView extends StatefulWidget {
  final BookPosition pos;
  const _ChaptersView(this.pos);

  @override
  _ChaptersViewState createState() => _ChaptersViewState();
}

class _ChaptersViewState extends State<_ChaptersView> {
  bool ready = false;
  BookPosition get pos => widget.pos;
  late int numChapters;

  @override
  void initState() {
    super.initState();

    pos.model!.getNumChapters(pos.index!).then((_numChapters) => setState(() {
          numChapters = _numChapters;
          ready = true;
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) return Container();

    return Wrap(
        spacing: 0.0,
        runSpacing: 0.0,
        children: List<int>.generate(numChapters, (i) => i + 1)
            .map((i) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => BookPositionNotification(
                        BookPosition.modelIndex(pos.model, pos.index, chapter: i - 1))
                    .dispatch(context),
                child: SizedBox(
                    width: 50,
                    height: 50,
                    child:
                        Center(child: Text("$i", style: Theme.of(context).textTheme.titleLarge)))))
            .toList());
  }
}

class BookTOC extends StatefulWidget {
  final BookModel model;
  const BookTOC(this.model);

  @override
  _BookTOCState createState() => _BookTOCState();
}

class _BookTOCState extends State<BookTOC> {
  BookModel get model => widget.model;

  List<String> get sections => model.getSections();

  TextStyle getFontCS(TextStyle font) =>
      font.copyWith(fontFamily: "Ponomar", fontSize: font.fontSize! + 3.0);

  Widget getContent() {
    var fontTitleOrig = Theme.of(context).textTheme.titleLarge!;
    var fontLabelOrig = Theme.of(context).textTheme.labelLarge!;

    if (widget.model.lang == "cs") {
      fontTitleOrig = getFontCS(fontTitleOrig);
      fontLabelOrig = getFontCS(fontLabelOrig);
    }

    return NotificationListener<Notification>(
        onNotification: (n) {
          if (n is BookPositionNotification) {
            BookPosition? pos = n.pos;
            final model = pos.model!;

            if (model is BookmarksModel) {
              pos = model.resolveBookmarkAt(pos.index!.index);
              if (pos == null) return true;

              if (pos.model is BibleModel) {
                // this is needed to initialize numChaptersCache in BibleModel
                pos.model!
                    .getNumChapters(pos.index!)
                    .then((value) => BookPageMultiple(pos!).push(context));
                return true;
              }
            }

            BookPageMultiple(pos).push(context);
          }
          return true;
        },
        child: sections.isEmpty
            ? Center(
                child: Text("no_bookmarks".tr(), style: Theme.of(context).textTheme.titleLarge))
            : GroupListView(
                shrinkWrap: true,
                sectionsCount: sections.length,
                countOfItemInSection: (int section) => model.getItems(section).length,
                itemBuilder: (BuildContext context, IndexPath index) {
                  final item = model.getItems(index.section)[index.index];
                  var fontTitle = fontTitleOrig;

                  if (model is BookmarksModel) {
                    final pos = (model as BookmarksModel).resolveBookmarkAt(index.index);
                    if (pos != null && pos.model is BibleModel && pos.model!.lang == "cs") {
                      fontTitle = getFontCS(fontTitle);
                    }
                  }

                  return ListTileTheme(
                      contentPadding: const EdgeInsets.all(0),
                      dense: true,
                      child: model.hasChapters
                          ? ExpansionTile(
                              childrenPadding: const EdgeInsets.all(10),
                              expandedAlignment: Alignment.topLeft,
                              expandedCrossAxisAlignment: CrossAxisAlignment.start,
                              trailing: const Icon(null),
                              title: Text(item, style: fontTitle),
                              children: [_ChaptersView(BookPosition.modelIndex(model, index))])
                          : ListTile(
                              title: Text(item, style: fontTitle),
                              onTap: () =>
                                  BookPositionNotification(BookPosition.modelIndex(model, index))
                                      .dispatch(context)));
                },
                groupHeaderBuilder: (BuildContext context, int section) =>
                    sections[section].isNotEmpty
                        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(sections[section].toUpperCase(), style: fontLabelOrig),
                            const Divider(thickness: 1)
                          ])
                        : Container(),
                separatorBuilder: (context, index) => const SizedBox(),
                sectionSeparatorBuilder: (context, section) => const SizedBox(height: 15),
              ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: MediaQuery.of(context).size.height,
            decoration:
                AppTheme.bg_decor_2() ?? BoxDecoration(color: Theme.of(context).canvasColor),
            child: SafeArea(
                child: NestedScrollView(
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
                          CalendarAppbar(
                              title: model.title, showActions: false, lang: widget.model.lang)
                        ],
                    body: Padding(padding: const EdgeInsets.all(15), child: getContent())))));
  }
}
