import 'package:flutter/material.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'globals.dart';
import 'bible_view.dart';

typedef WidgetCallback = Widget Function();

class BookPageSingle extends StatefulWidget {
  final String title;
  final WidgetCallback builder;
  final double padding;
  final bool safeBottom;
  final bool showActions;
  final bool? bibleFontButton;
  final String? bookmark;

  const BookPageSingle(this.title,
      {required this.builder,
      this.bookmark,
      this.bibleFontButton,
      this.padding = 15,
      this.safeBottom = true,
      this.showActions = true});

  @override
  _BookPageSingleState createState() => _BookPageSingleState();
}

class _BookPageSingleState extends State<BookPageSingle> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(() => setState(() {}));
  }

  addBookmark() {
    final bookmarks = List<String>.from(ConfigParamExt.bookmarks.val());
    bookmarks.add(widget.bookmark!);
    ConfigParamExt.bookmarks.set(bookmarks);

    setState(() {});
  }

  removeBookmark() {
    final bookmarks = List<String>.from(ConfigParamExt.bookmarks.val());
    bookmarks.remove(widget.bookmark);
    ConfigParamExt.bookmarks.set(bookmarks);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    IconButton? bookmarkButton, bibleFontButton;

    if (widget.bookmark != null) {
      if (ConfigParamExt.bookmarks.val().contains(widget.bookmark)) {
        bookmarkButton = IconButton(
            icon: const Icon(Icons.bookmark, size: 30.0), onPressed: () => removeBookmark());
      } else {
        bookmarkButton = IconButton(
            icon: const Icon(Icons.bookmark_outline, size: 30.0), onPressed: () => addBookmark());
      }
    }

    if (widget.bibleFontButton == true) {
      bibleFontButton = IconButton(
          icon: const Icon(Icons.font_download_outlined, size: 30.0),
          onPressed: () => BibleLangDialog().show(context).then((value) => setState(() {})));
    }

    return Scaffold(
        body: Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: SafeArea(
                bottom: false,
                child: Scrollbar(
                    controller: _scrollController,
                    child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: AppTheme.bg_decor_2() ??
                            BoxDecoration(color: Theme.of(context).canvasColor),
                        child: SafeArea(
                            bottom: widget.safeBottom,
                            child: CustomScrollView(
                                controller: _scrollController,
                                physics: const ClampingScrollPhysics(),
                                slivers: [
                                  SliverAppBar(
                                    elevation: 0.0,
                                    floating: true,
                                    toolbarHeight: 50.0,
                                    pinned: false,
                                    actions: widget.showActions
                                        ? [
                                            IconButton(
                                                icon:
                                                    const Icon(Icons.zoom_in_outlined, size: 30.0),
                                                onPressed: () => FontSizeDialog()
                                                    .show(context)
                                                    .then((value) => setState(() {}))),
                                            if (bookmarkButton != null) ...[bookmarkButton],
                                            if (bibleFontButton != null) ...[bibleFontButton]
                                          ]
                                        : [],
                                    title: Text(widget.title,
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context).textTheme.titleLarge),
                                  ),
                                  SliverToBoxAdapter(
                                      key: ValueKey(ConfigParam.fontSize.val()),
                                      child: Padding(
                                          padding: EdgeInsets.all(widget.padding),
                                          child: widget.builder()))
                                ])))))));
  }
}
