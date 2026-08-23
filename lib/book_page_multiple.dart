import 'package:flutter/material.dart';
import 'package:page_view_indicators/linear_progress_page_indicator.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:group_list_view/group_list_view.dart';

import 'dart:math';

import 'book_model.dart';
import 'bible_model.dart';
import 'book_page_single.dart';
import 'book_cell.dart';
import 'bible_view.dart';

class BookPageMultiple extends StatefulWidget {
  final BookPosition pos;

  BookPageMultiple(this.pos);

  @override
  _BookPageMultipleState createState() => _BookPageMultipleState();
}

class _BookPageMultipleState extends State<BookPageMultiple> {
  BookModel get model => widget.pos.model!;
  BookPosition get pos => widget.pos;

  List<BookPosition> bookPos = [];
  late int initialPos;
  int totalChapters = 0;

  late PageController _pageController;
  final _pageNotifier = ValueNotifier<int>(0);
  final Map<String, Future<dynamic>> _contentFutures = {};

  String _contentKey(BookPosition position) =>
      '${position.index!.section}_${position.index!.index}_${position.chapter ?? 0}';

  Future<dynamic> _getContent(BookPosition position) =>
      _contentFutures.putIfAbsent(_contentKey(position), () => model.getContent(position));

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

    _pageController = PageController(initialPage: initialPos);
    _pageNotifier.value = initialPos;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  Widget _buildPage(int id) {
    final pagePos = bookPos[id];

    return FutureBuilder<dynamic>(
        future: _getContent(pagePos),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (model is BibleModel) {
            return BibleChapterView(pagePos, safeBottom: totalChapters == 1);
          }

          final title = model.getTitle(pagePos);
          final text = snapshot.data;

          if (model.contentType == BookContentType.html) {
            return BookPageSingle(title,
                bookmark: model.getBookmark(pagePos),
                builder: () => BookCellHTML(text, model),
                padding: 5,
                safeBottom: totalChapters == 1);
          }

          return BookPageSingle(title,
              bookmark: model.getBookmark(pagePos),
              builder: () => BookCellText(text),
              safeBottom: totalChapters == 1);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child: PageView.builder(
              controller: _pageController,
              itemCount: totalChapters,
              onPageChanged: (index) => _pageNotifier.value = index,
              itemBuilder: (context, id) => _buildPage(id))),
      if (totalChapters > 1) ...[
        LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) => Stack(children: [
                  LinearProgressPageIndicator(
                    itemCount: totalChapters,
                    currentPageNotifier: _pageNotifier,
                    progressColor: Theme.of(context).primaryColor,
                    duration: const Duration(microseconds: 0),
                    width: constraints.maxWidth,
                    height: 40,
                  ),
                  Center(
                      child: ValueListenableBuilder<int>(
                          valueListenable: _pageNotifier,
                          builder: (context, page, _) => DotsIndicator(
                                dotsCount: min(totalChapters, 10),
                                position: page.toDouble(),
                                decorator: const DotsDecorator(
                                  color: Colors.grey,
                                  activeColor: Colors.grey,
                                ),
                              )))
                ]))
      ]
    ]));
  }
}
