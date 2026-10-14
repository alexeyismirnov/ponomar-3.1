import 'package:flutter/material.dart';

import 'book_model.dart';
import 'book_page_multiple.dart';
import 'book_toc.dart';
import 'layout_info.dart';
import 'library_page.dart';

/// Responsive library entry point: 3-pane dashboard on wide screens,
/// classic push navigation on phones.
class LibraryTab extends StatelessWidget {
  const LibraryTab();

  @override
  Widget build(BuildContext context) =>
      LayoutInfo.useNavigationRail(context) ? const LibraryDashboard() : LibraryPage();
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

  void _onBookSelected(BookModel model) => setState(() {
        _book = model;
        _pos = null;
      });

  void _onPositionSelected(BookPosition pos) => setState(() => _pos = pos);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 1000;

      final listPane = SizedBox(
          width: 280,
          child: Padding(
              padding: const EdgeInsets.only(left: 15, top: 15),
              child: LibraryListView(onBookSelected: _onBookSelected)));

      final tocPane = _book == null
          ? Center(
              child: Icon(Icons.menu_book_outlined,
                  size: 40.0, color: Theme.of(context).secondaryHeaderColor))
          : BookTOC(
              key: ValueKey(_book),
              _book!,
              embedded: true,
              onPositionSelected: _onPositionSelected);

      Widget readerPane = _pos == null
          ? Center(
              child: Icon(Icons.auto_stories_outlined,
                  size: 40.0, color: Theme.of(context).secondaryHeaderColor))
          : BookPageMultiple(key: ValueKey(_pos), _pos!, embedded: true);

      if (wide) {
        return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          listPane,
          const VerticalDivider(width: 1, thickness: 1),
          SizedBox(width: 300, child: tocPane),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: readerPane)
        ]);
      }

      // Narrow tablet: list + one content pane (TOC until a chapter is
      // selected, then the reader with a back button).
      return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        listPane,
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
            child: _pos == null
                ? tocPane
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    TextButton.icon(
                        onPressed: () => setState(() => _pos = null),
                        icon: const Icon(Icons.chevron_left),
                        label: Text(_book!.title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium)),
                    const Divider(height: 1, thickness: 1),
                    Expanded(child: readerPane)
                  ]))
      ]);
    }));
  }
}
