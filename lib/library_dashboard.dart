import 'package:flutter/material.dart';

import 'book_model.dart';
import 'book_page_multiple.dart';
import 'book_toc.dart';
import 'expandable_reader.dart';
import 'layout_info.dart';
import 'library_page.dart';

/// Responsive library entry point: 3-pane dashboard on tablets in landscape,
/// classic push navigation on phones and on tablets held in portrait (with a
/// dismissible hint that landscape offers a better layout).
class LibraryTab extends StatelessWidget {
  const LibraryTab();

  @override
  Widget build(BuildContext context) {
    if (LayoutInfo.isPortraitTablet(context)) {
      return const _PortraitTabletLibrary();
    }

    return LayoutInfo.useNavigationRail(context)
        ? const LibraryDashboard()
        : LibraryPage();
  }
}

/// Phone-style library for tablets in portrait, topped by a closable banner
/// suggesting rotation to landscape.
class _PortraitTabletLibrary extends StatelessWidget {
  const _PortraitTabletLibrary();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LandscapeLayoutHintBanner(),
        Expanded(child: LibraryPage()),
      ],
    );
  }
}

/// Tablet library: grouped book list → embedded TOC → embedded reader.
class LibraryDashboard extends StatefulWidget {
  const LibraryDashboard();

  @override
  _LibraryDashboardState createState() => _LibraryDashboardState();
}

class _LibraryDashboardState extends State<LibraryDashboard> {
  BookModel? _book;
  BookPosition? _pos;
  bool _readerExpanded = false;

  void _onBookSelected(BookModel model) => setState(() {
        _book = model;
        _pos = null;
      });

  void _onPositionSelected(BookPosition pos) => setState(() => _pos = pos);

  void _toggleExpand() => setState(() => _readerExpanded = !_readerExpanded);

  List<Widget> get _expandAction =>
      [PaneExpandButton(expanded: _readerExpanded, onPressed: _toggleExpand)];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1000;

          final listPane = SizedBox(
            width: 280,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, top: 15),
              child: LibraryListView(onBookSelected: _onBookSelected),
            ),
          );

          final tocPane = _book == null
              ? Center(
                  child: Icon(
                    Icons.menu_book_outlined,
                    size: 40.0,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                )
              : BookTOC(
                  key: ValueKey(_book),
                  _book!,
                  embedded: true,
                  onPositionSelected: _onPositionSelected,
                );

          Widget readerPane = _pos == null
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      height: 50.0,
                      child: Row(children: [
                        const Spacer(),
                        ..._expandAction,
                        const SizedBox(width: 5),
                      ])),
                  const Divider(height: 1, thickness: 1),
                  Expanded(
                      child: Center(
                          child: Icon(
                    Icons.auto_stories_outlined,
                    size: 40.0,
                    color: Theme.of(context).secondaryHeaderColor,
                  ))),
                ])
              : BookPageMultiple(
                  key: ValueKey(_pos),
                  _pos!,
                  embedded: true,
                  extraActions: _expandAction,
                );

          if (wide) {
            return ExpandablePanes(
              expanded: _readerExpanded,
              leading: [
                listPane,
                const VerticalDivider(width: 1, thickness: 1),
                SizedBox(width: 300, child: tocPane),
                const VerticalDivider(width: 1, thickness: 1),
              ],
              reader: readerPane,
            );
          }

          // Narrow tablet: list + one content pane (TOC until a chapter is
          // selected, then the reader with a back button).
          final content = _pos == null
              ? tocPane
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() => _pos = null),
                      icon: const Icon(Icons.chevron_left),
                      label: Text(
                        _book!.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                    Expanded(child: readerPane),
                  ],
                );

          return ExpandablePanes(
            expanded: _readerExpanded,
            leading: [
              listPane,
              const VerticalDivider(width: 1, thickness: 1),
            ],
            reader: _pos == null
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(
                        height: 50.0,
                        child: Row(children: [
                          const Spacer(),
                          ..._expandAction,
                          const SizedBox(width: 5),
                        ])),
                    const Divider(height: 1, thickness: 1),
                    Expanded(child: content),
                  ])
                : content,
          );
        },
      ),
    );
  }
}
