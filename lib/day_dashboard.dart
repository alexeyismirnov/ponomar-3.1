import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'church_reading.dart';
import 'day_scope.dart';
import 'day_view.dart';
import 'expandable_reader.dart';
import 'globals.dart';
import 'layout_info.dart';
import 'month_rail.dart';
import 'pericope.dart';
import 'bible_view.dart';

/// Tablet day view: month rail + day summary pane + reader pane.
/// Reading tiles route their content here via [DayScope] instead of pushing
/// full-screen pages.
class DayDashboard extends StatefulWidget {
  final DateTime date;

  const DayDashboard({Key? key, required this.date}) : super(key: key);

  @override
  _DayDashboardState createState() => _DayDashboardState();
}

class _DayDashboardState extends State<DayDashboard> {
  ReadingSelection? _selection;
  bool _readerExpanded = false;

  @override
  void initState() {
    super.initState();
    _selection = _defaultSelection();
  }

  /// Preselect the first Reading of the day so the reader pane is never empty.
  ReadingSelection? _defaultSelection() {
    final reading = ChurchReading.forDate(widget.date);
    if (reading.isEmpty) return null;

    final r = reading.first.split("#").first.trim();
    return ReadingSelection(
        title: "Reading of the day".tr(),
        bibleFontButton: true,
        builder: () =>
            PericopeView(key: ValueKey(ConfigParamExt.bibleLang.val()), r));
  }

  @override
  Widget build(BuildContext context) {
    final layout = LayoutInfo.dayViewLayout(context);

    final leading = <Widget>[
      if (layout == DayViewLayout.dashboard) ...[
        SingleChildScrollView(child: MonthRail(date: widget.date)),
        const VerticalDivider(width: 1, thickness: 1),
      ],
      SizedBox(
          width: layout == DayViewLayout.dashboard ? 380 : 340,
          child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              children: dayViewSections(widget.date))),
      const VerticalDivider(width: 1, thickness: 1),
    ];

    return DayScope(
        onReadingSelected: (sel) => setState(() => _selection = sel),
        child: ExpandablePanes(
            expanded: _readerExpanded,
            leading: leading,
            reader: _ReaderPane(_selection,
                expanded: _readerExpanded,
                onToggleExpand: () => setState(() => _readerExpanded = !_readerExpanded),
                onFontChanged: () => setState(() {}))));
  }
}

class _ReaderPane extends StatelessWidget {
  final ReadingSelection? selection;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onFontChanged;

  const _ReaderPane(this.selection,
      {required this.expanded, required this.onToggleExpand, required this.onFontChanged});

  @override
  Widget build(BuildContext context) {
    if (selection == null) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            height: 50.0,
            child: Row(children: [
              const Spacer(),
              PaneExpandButton(expanded: expanded, onPressed: onToggleExpand),
              const SizedBox(width: 5),
            ])),
        const Divider(height: 1, thickness: 1),
        Expanded(
            child: Center(
                child: Text("Reading of the day".tr(),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: Theme.of(context).secondaryHeaderColor))))
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
          height: 50.0,
          child: Row(children: [
            const SizedBox(width: 15),
            Expanded(
                child: AutoSizeText(selection!.title,
                    maxLines: 1,
                    minFontSize: 5,
                    style: Theme.of(context).textTheme.titleLarge)),
            if (selection!.bibleFontButton && context.languageCode == "ru") ...[
              IconButton(
                  icon: const Icon(Icons.font_download_outlined, size: 30.0),
                  onPressed: () =>
                      BibleLangDialog().show(context).then((_) => onFontChanged()))
            ],
            PaneExpandButton(expanded: expanded, onPressed: onToggleExpand),
            const SizedBox(width: 5),
          ])),
      const Divider(height: 1, thickness: 1),
      Expanded(
          child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
            key: ValueKey(ConfigParam.fontSize.val()),
            child: Padding(padding: const EdgeInsets.all(15), child: selection!.builder()))
      ]))
    ]);
  }
}
