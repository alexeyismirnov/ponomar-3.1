import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'church_fasting.dart';
import 'month_cell.dart';

class MonthInfoContainer extends StatefulWidget {
  final DateTime initialDate;

  /// Rail mode is used inside the tablet month rail: no info toggle,
  /// compact header with month chevrons, cell taps are reported via
  /// [onCellSelected] and [selectedDate] is ringed.
  final bool railMode;
  final void Function(DateTime date)? onCellSelected;
  final DateTime? selectedDate;

  const MonthInfoContainer(this.initialDate,
      {Key? key, this.railMode = false, this.onCellSelected, this.selectedDate})
      : super(key: key);

  @override
  _MonthInfoContainerState createState() => _MonthInfoContainerState();
}

class _MonthInfoContainerState extends State<MonthInfoContainer> {
  static const initialPage = 100000;
  late PageController _controller;

  late String title;
  bool showInfo = false;

  @override
  void initState() {
    super.initState();

    _controller = PageController(initialPage: initialPage);
    updateTitle();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MonthInfoContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.railMode) return;

    if (widget.initialDate != oldWidget.initialDate) {
      // Selected month changed (Today / cell / feast link): show that month.
      _jumpToInitialMonth();
      return;
    }

    // Same selected month, but the user may have browsed away with chevrons.
    _syncToSelectedMonth();
  }

  void _jumpToInitialMonth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.jumpToPage(initialPage);
      updateTitle(initialPage);
    });
  }

  void _syncToSelectedMonth() {
    final sel = widget.selectedDate;
    if (sel == null || !_controller.hasClients) return;

    final page = _controller.page?.round() ?? initialPage;
    final shown =
        Jiffy.parseFromDateTime(widget.initialDate).add(months: page - initialPage);

    if (shown.year == sel.year && shown.month == sel.month) return;

    // [MonthRail] always passes initialDate = month-start of selectedDate.
    _jumpToInitialMonth();
  }

  void updateTitle([int index = initialPage]) {
    final currentDate =
        Jiffy.parseFromDateTime(widget.initialDate).add(months: index - initialPage);

    setState(() {
      title = currentDate.format(pattern: "LLLL yyyy").capitalize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacer = SizedBox(height: widget.railMode ? 5 : 10);
    final config = MonthViewConfig.of(context)!;

    Widget header;

    if (widget.railMode) {
      header = Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
                onPressed: () => _controller.previousPage(
                    duration: const Duration(milliseconds: 200), curve: Curves.easeOut),
                iconSize: 22.0,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.chevron_left)),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            IconButton(
                onPressed: () => _controller.nextPage(
                    duration: const Duration(milliseconds: 200), curve: Curves.easeOut),
                iconSize: 22.0,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.chevron_right)),
          ]);
    } else {
      header = Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const SizedBox(width: 40),
            Text(showInfo ? "info".tr() : title,
                style: Theme.of(context).textTheme.titleLarge),
            showInfo
                ? IconButton(
                    onPressed: () => setState(() => showInfo = false),
                    iconSize: 30.0,
                    icon: const Icon(Icons.close_sharp))
                : IconButton(
                    onPressed: () => setState(() => showInfo = true),
                    iconSize: 30.0,
                    icon: const Icon(Icons.help_outline)),
          ]);
    }

    return Container(
        width: config.containerWidth,
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              header,
              if (!showInfo) ...[WeekdaysView()],
              spacer,
              SizedBox(
                  width: config.containerWidth,
                  height: config.cellWidth * 6,
                  child: showInfo
                      ? SingleChildScrollView(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: FastingModel.types
                                      .map<Widget>((t) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0, vertical: 3),
                                          child: Row(children: [
                                            Container(width: 30, height: 30, color: t.color),
                                            const SizedBox(width: 10),
                                            Expanded(
                                                child: Text(t.description.tr(),
                                                    style: Theme.of(context).textTheme.titleLarge))
                                          ])))
                                      .toList())))
                      : PageView.builder(
                          // Rail mode must not use PageStorage: browsing with
                          // chevrons then jumping via "Today" / date selection
                          // would restore a stale page while the title resets.
                          key: widget.railMode
                              ? null
                              : const PageStorageKey("monthview"),
                          controller: _controller,
                          onPageChanged: (page) => updateTitle(page),
                          itemBuilder: (BuildContext context, int index) {
                            final cd = Jiffy.parseFromDateTime(widget.initialDate)
                                .add(months: index - initialPage)
                                .dateTime;

                            return Align(
                                alignment: Alignment.topCenter,
                                child: MonthView(DateTime.utc(cd.year, cd.month, cd.day),
                                    cellBuilder: (date) => MonthViewCell(date,
                                        onSelected: widget.onCellSelected,
                                        selectedDate: widget.selectedDate)));
                          })),
              if (showInfo) ...[const SizedBox(height: 20)]
            ]));
  }
}
