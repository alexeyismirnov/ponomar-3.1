import 'package:flutter/material.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

typedef WidgetCallback = Widget Function();

class BookPageSingle extends StatefulWidget {
  final String title;
  final WidgetCallback builder;
  final double padding;
  final bool safeBottom;
  final bool showActions;

  const BookPageSingle(this.title,
      {required this.builder, this.padding = 15, this.safeBottom = true, this.showActions = true});

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

  @override
  Widget build(BuildContext context) {
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
                                                    .then((value) => setState(() {})))
                                          ]
                                        : [],
                                    title: Text(widget.title,
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context).textTheme.headline6),
                                  ),
                                  SliverToBoxAdapter(
                                      key: ValueKey(ConfigParam.fontSize.val()),
                                      child: Padding(
                                          padding: EdgeInsets.all(widget.padding),
                                          child: widget.builder()))
                                ])))))));
  }
}
