import 'package:flutter/material.dart';
import 'package:page_view_indicators/linear_progress_page_indicator.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:group_list_view/group_list_view.dart';

import 'dart:math';

import 'book_model.dart';
import 'bible_model.dart';
import 'book_page_single.dart';
import 'book_cell.dart';
import 'pericope.dart';

class BookPageMultiple extends StatefulWidget {
  final BookPosition pos;

  BookPageMultiple(this.pos);

  @override
  _BookPageMultipleState createState() => _BookPageMultipleState();
}

class _BookPageMultipleState extends State<BookPageMultiple> with SingleTickerProviderStateMixin {
  BookModel get model => widget.pos.model!;
  BookPosition get pos => widget.pos;

  List<BookPosition> bookPos = [];
  late int initialPos;
  int totalChapters = 0;

  late TabController _tabController;
  final _pageNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    BookPosition? curPos = (model.hasChapters)
        ? BookPosition.modelIndex(model, pos.index!, chapter: 0)
        : BookPosition.modelIndex(model, IndexPath(section: 0, index: 0));

    do {
      bookPos.add(curPos!);

      if (curPos == pos) {
        initialPos = totalChapters;
      }

      totalChapters++;
      curPos = model.getNextSection(curPos);
    } while (curPos != null);

    _tabController = TabController(vsync: this, length: totalChapters, initialIndex: initialPos)
      ..addListener(_handleTabSelection);

    _pageNotifier.value = initialPos;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() => _pageNotifier.value = _tabController.index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child: TabBarView(
              controller: _tabController,
              children: List<Widget>.generate(
                  totalChapters,
                  (id) => FutureBuilder(
                      future:
                          Future.wait([model.getTitle(bookPos[id]), model.getContent(bookPos[id])]),
                      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (!snapshot.hasData) return Container();

                        if (model is BibleModel) {
                          return BibleChapterView(bookPos[id], safeBottom: totalChapters == 1);
                        } else {
                          String title = snapshot.data![0];
                          var text = snapshot.data![1];

                          if (model.contentType == BookContentType.html) {
                            return BookPageSingle(title,
                                builder: () => BookCellHTML(text, model),
                                padding: 5,
                                safeBottom: totalChapters == 1);
                          } else {
                            return BookPageSingle(title,
                                builder: () => BookCellText(text), safeBottom: totalChapters == 1);
                          }
                        }
                      })).toList())),
      if (totalChapters > 1) ...[
        LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) => Stack(children: [
                  LinearProgressPageIndicator(
                    itemCount: _tabController.length,
                    currentPageNotifier: _pageNotifier,
                    progressColor: Theme.of(context).primaryColor,
                    duration: const Duration(microseconds: 0),
                    width: constraints.maxWidth,
                    height: 40,
                  ),
                  Center(
                      child: DotsIndicator(
                    dotsCount: min(totalChapters, 10),
                    position: 0,
                    decorator: const DotsDecorator(
                      color: Colors.grey, // Inactive color
                      activeColor: Colors.grey,
                    ),
                  )),
                ]))
      ]
    ]));
  }
}
