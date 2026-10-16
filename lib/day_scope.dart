import 'package:flutter/material.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'book_page_single.dart';

/// A piece of day content that can be shown either in the tablet dashboard's
/// reader pane or pushed as a full-screen page on phones.
class ReadingSelection {
  final String title;
  final Widget Function() builder;
  final bool bibleFontButton;

  const ReadingSelection(
      {required this.title, required this.builder, this.bibleFontButton = false});
}

/// Present in the widget tree on tablet layouts (see DayDashboard). Reading
/// tiles use [openReading] which routes the content to the reader pane when a
/// scope is available, and falls back to push navigation otherwise.
class DayScope extends InheritedWidget {
  final void Function(ReadingSelection selection) onReadingSelected;

  const DayScope({Key? key, required this.onReadingSelected, required Widget child})
      : super(key: key, child: child);

  static DayScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DayScope>();

  @override
  bool updateShouldNotify(DayScope oldWidget) => false;
}

void openReading(BuildContext context,
    {required String title,
    required Widget Function() builder,
    bool bibleFontButton = false,
    bool showActions = true}) {
  final scope = DayScope.maybeOf(context);

  if (scope != null) {
    scope.onReadingSelected(
        ReadingSelection(title: title, builder: builder, bibleFontButton: bibleFontButton));
  } else {
    BookPageSingle(title,
            builder: builder, bibleFontButton: bibleFontButton, showActions: showActions)
        .push(context);
  }
}
