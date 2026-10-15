import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'globals.dart';
import 'month_info_container.dart';
import 'year_calendar.dart';

/// Left rail of the tablet day dashboard: the real month grid with fasting
/// colors, month chevrons, a ring on the selected date, plus "today" and
/// "year calendar" buttons.
class MonthRail extends StatelessWidget {
  final DateTime date;

  const MonthRail({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final monthStart = DateTime.utc(date.year, date.month, 1);

    return Container(
        width: 280,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          MonthViewConfig(
              lang: context.languageCode,
              cellWidth: 36.0,
              containerWidth: 256.0,
              child: MonthInfoContainer(monthStart,
                  key: ValueKey(monthStart),
                  railMode: true,
                  selectedDate: date,
                  onCellSelected: (d) => DateChangedNotification(d).dispatch(context))),
          const SizedBox(height: 5),
          TextButton.icon(
              onPressed: () {
                final now = DateTime.now();
                DateChangedNotification(DateTime.utc(now.year, now.month, now.day))
                    .dispatch(context);
              },
              icon: const Icon(Icons.today_outlined, size: 20.0),
              label: Text('today'.tr(), style: Theme.of(context).textTheme.titleMedium)),
          TextButton.icon(
              onPressed: () {
                MonthViewConfig(
                        lang: context.languageCode,
                        sharing: false,
                        shortLabels: true,
                        highlightToday: false,
                        child: YearContainer(date))
                    .push(context)
                    .then((newDate) {
                  if (newDate is DateTime) {
                    DateChangedNotification(newDate).dispatch(context);
                  }
                });
              },
              icon: const Icon(Icons.calendar_month_outlined, size: 20.0),
              label: Text('yearly'.tr(), style: Theme.of(context).textTheme.titleMedium))
        ]));
  }
}
