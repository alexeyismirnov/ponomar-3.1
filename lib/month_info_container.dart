import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'church_fasting.dart';
import 'month_cell.dart';

class MonthInfoContainer extends StatefulWidget {
  final DateTime initialDate;
  const MonthInfoContainer(this.initialDate);

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

  void updateTitle([int index = initialPage]) {
    final currentDate =
        Jiffy.parseFromDateTime(widget.initialDate).add(months: index - initialPage);

    setState(() {
      title = currentDate.format(pattern: "LLLL yyyy").capitalize();
    });
  }

  @override
  Widget build(BuildContext context) {
    const spacer = SizedBox(height: 10);
    final config = MonthViewConfig.of(context)!;

    return Container(
        width: config.containerWidth,
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
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
                  ]),
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
                          key: const PageStorageKey("monthview"),
                          controller: _controller,
                          onPageChanged: (page) => updateTitle(page),
                          itemBuilder: (BuildContext context, int index) {
                            final cd = Jiffy.parseFromDateTime(widget.initialDate)
                                .add(months: index - initialPage)
                                .dateTime;

                            return Align(
                                alignment: Alignment.topCenter,
                                child: MonthView(DateTime.utc(cd.year, cd.month, cd.day),
                                    cellBuilder: (date) => MonthViewCell(date)));
                          })),
              if (showInfo) ...[const SizedBox(height: 20)]
            ]));
  }
}
