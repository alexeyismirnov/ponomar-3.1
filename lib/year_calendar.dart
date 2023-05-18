import 'package:flutter/material.dart';

import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';

import 'dart:io';
import 'dart:core';
import 'dart:typed_data';

import 'globals.dart';
import 'church_fasting.dart';
import 'month_cell.dart';

class YearMonthView extends StatefulWidget {
  final int year;
  const YearMonthView(this.year);

  @override
  _YearMonthViewState createState() => _YearMonthViewState();
}

class _YearMonthViewState extends State<YearMonthView> {
  @override
  Widget buildMonth(BuildContext context, DateTime date) {
    final config = MonthViewConfig.of(context)!;

    Color textColor =
        config.sharing ? Colors.black : Theme.of(context).textTheme.headlineMedium!.color!;

    return FittedBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(DateFormat("LLLL").format(date).capitalize(),
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: textColor)),
      const SizedBox(height: 10),
      SizedBox(width: config.containerWidth, child: WeekdaysView()),
      ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: config.containerWidth,
              minWidth: config.containerWidth,
              maxHeight: config.cellWidth * 6),
          child: Align(
              alignment: Alignment.topCenter,
              child: MonthView(date, cellBuilder: (date) => MonthViewCell(date))))
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final config = MonthViewConfig.of(context)!;

    Color textColor = config.sharing ? Colors.black : Theme.of(context).textTheme.subtitle1!.color!;

    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(mainAxisSize: MainAxisSize.max, children: [
              GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  children: List<int>.generate(12, (i) => i)
                      .map<Widget>((i) => buildMonth(context, DateTime.utc(widget.year, i + 1, 1)))
                      .toList()),
              const SizedBox(height: 20),
              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 50, // here set custom Height You Want
                  ),
                  itemCount: FastingModel.types.length,
                  itemBuilder: (BuildContext context, int i) {
                    final t = FastingModel.types[i];

                    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 20, height: 20, color: t.color),
                      const SizedBox(width: 10),
                      Expanded(
                          child: AutoSizeText(t.description.tr(),
                              maxLines: 2,
                              minFontSize: 5,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(color: textColor)))
                    ]);
                  })
            ])));
  }
}

class YearContainer extends StatefulWidget {
  final DateTime date;
  const YearContainer(this.date);

  @override
  _YearContainerState createState() => _YearContainerState();
}

class _YearContainerState extends State<YearContainer> {
  static const initialPage = 100000;
  late int initialYear;

  late String title;
  late PageController _controller;
  ScreenshotController screenshotController = ScreenshotController();

  late int currentPage;

  @override
  void initState() {
    super.initState();

    initialYear = widget.date.year;

    _controller = PageController(initialPage: initialPage);
    updateTitle();
  }

  void updateTitle([int index = initialPage]) {
    currentPage = index;
    setState(() {
      title = "year_calendar".tr().format([index - initialPage + initialYear]);
    });
  }

  Widget getAppbar() => SliverAppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        floating: false,
        pinned: false,
        toolbarHeight: 50.0,
        actions: [
          IconButton(
              icon: const Icon(Icons.share_outlined, size: 30.0),
              onPressed: () async {
                var path = p.join(GlobalPath.documents, 'screenshot.png');
                print(path);

                Uint8List pngBytes = (await screenshotController.captureFromWidget(EasyLocalization(
                    supportedLocales: const [
                      Locale('en', ''),
                    ],
                    path: 'ui,cal,reading,library',
                    assetLoader: DirectoryAssetLoader(basePath: "assets/translations"),
                    fallbackLocale: const Locale('en', ''),
                    startLocale: const Locale('en', ''),
                    child: MonthViewConfig(
                        lang: context.languageCode,
                        sharing: true,
                        shortLabels: true,
                        highlightToday: false,
                        child: Container(
                            color: Colors.white,
                            child: YearMonthView(currentPage - initialPage + initialYear))))));

                final file = File(path);
                await file.writeAsBytes(pngBytes, flush: true);

                await Share.shareFiles([path]);
              }),
        ],
        title: AutoSizeText(title,
            maxLines: 1,
            minFontSize: 5,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: MediaQuery.of(context).size.height,
            decoration:
                AppTheme.bg_decor_2() ?? BoxDecoration(color: Theme.of(context).canvasColor),
            child: SafeArea(
                child: NestedScrollView(
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
                        [getAppbar()],
                    body: PageView.builder(
                        controller: _controller,
                        onPageChanged: (page) => updateTitle(page),
                        itemBuilder: (BuildContext context, int index) =>
                            YearMonthView(index - initialPage + initialYear))))));
  }
}
