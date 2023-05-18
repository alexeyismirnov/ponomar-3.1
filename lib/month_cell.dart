import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'globals.dart';
import 'church_fasting.dart';
import 'church_calendar.dart';

class MonthViewCell extends StatelessWidget {
  final DateTime date;
  const MonthViewCell(this.date);

  @override
  Widget build(BuildContext context) {
    var config = MonthViewConfig.of(context)!;

    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);

    return FutureBuilder<FastingModel>(
        future: ChurchFasting.forDate(date, context.countryCode),
        builder: (BuildContext context, AsyncSnapshot<FastingModel> snapshot) {
          if (!snapshot.hasData) return Container();

          Color themeColor =
              config.sharing ? Colors.black : Theme.of(context).textTheme.titleLarge!.color!;

          final fasting = snapshot.data!;

          Color? textColor;
          FontWeight fontWeight;

          if (Cal.getGreatFeast(date).isNotEmpty) {
            fontWeight = FontWeight.bold;
            textColor = Colors.red;
          } else {
            fontWeight = FontWeight.normal;

            textColor =
                fasting.type == FastingType.noFast || fasting.type == FastingType.noFastMonastic
                    ? themeColor
                    : Colors.black;
          }

          if (date == today && config.highlightToday) {
            textColor = Colors.white;
          }

          Widget content = Center(
              child: AutoSizeText("${date.day}",
                  maxLines: 1,
                  minFontSize: 5,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: fontWeight, color: textColor)));

          Widget wrapper;

          if (date == today && config.highlightToday) {

            wrapper = Container(
                width: config.cellWidth,
                height: config.cellHeight,
                color: fasting.type.color,
                child: Container(
                    width: config.cellWidth,
                    height: config.cellHeight,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: content));
          } else {
            wrapper = Container(
                width: config.cellWidth,
                height: config.cellHeight,
                color: fasting.type.color,
                child: content);
          }

          return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pop(context, date);
              },
              child: wrapper);
        });
  }
}
