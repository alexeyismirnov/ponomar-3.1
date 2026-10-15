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

  /// Embedded mode renders the pager without a Scaffold so it can live
  /// inside a tablet reader pane.
  final bool embedded;

  BookPageMultiple(this.pos, {Key? key, this.embedded = false})
    : super(key: key);

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

  Future<dynamic> _getContent(BookPosition position) => _contentFutures
      .putIfAbsent(_contentKey(position), () => model.getContent(position));

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
          return BibleChapterView(
            pagePos,
            safeBottom: totalChapters == 1,
            embedded: widget.embedded,
          );
        }

        final title = model.getTitle(pagePos);
        final text = snapshot.data;

        if (model.contentType == BookContentType.html) {
          return BookPageSingle(
            title,
            bookmark: model.getBookmark(pagePos),
            builder: () => BookCellHTML(text, model),
            padding: 5,
            safeBottom: totalChapters == 1,
            embedded: widget.embedded,
          );
        }

        return BookPageSingle(
          title,
          bookmark: model.getBookmark(pagePos),
          builder: () => BookCellText(text),
          safeBottom: totalChapters == 1,
          embedded: widget.embedded,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalChapters,
            onPageChanged: (index) => _pageNotifier.value = index,
            itemBuilder: (context, id) => _buildPage(id),
          ),
        ),
        // In embedded mode (tablet 3-pane landscape) the chapter grid is
        // already visible in the middle panel, so no progress indicator
        // (bar or dots) is shown in the reader pane.
        if (totalChapters > 1 && !widget.embedded) ...[
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) => Stack(
              children: [
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
                    builder: (context, page, _) {
                      const maxDots = 10;
                      final dots = min(totalChapters, maxDots);
                      // DotsIndicator asserts position < dotsCount, so when the
                      // chapter count exceeds the dot cap, scale the raw page
                      // index from chapter space into dot space.
                      final position = totalChapters > maxDots
                          ? page * maxDots / totalChapters
                          : page.toDouble();

                      return DotsIndicator(
                        dotsCount: dots,
                        position: position.clamp(0.0, dots - 1.0),
                        decorator: const DotsDecorator(
                          color: Colors.grey,
                          activeColor: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    return widget.embedded ? SafeArea(child: content) : Scaffold(body: content);
  }
}
