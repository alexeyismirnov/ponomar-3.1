import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'month_info_container.dart';
import 'year_calendar.dart';
import 'globals.dart';

class CalendarSelector extends StatelessWidget {
  final DateTime date;
  CalendarSelector(this.date);

  @override
  Widget build(BuildContext context) => SelectorDialog(title: 'calendar', content: [
        ListTile(
            dense: true,
            title: Text('today'.tr(),
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            onTap: () {
              final d = DateTime.now();
              Navigator.pop(context, DateTime.utc(d.year, d.month, d.day));
            }),
        ListTile(
            dense: true,
            title: Text('monthly'.tr(),
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            onTap: () {
              var dialog = AlertDialog(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  contentPadding: const EdgeInsets.all(5.0),
                  insetPadding: const EdgeInsets.all(0.0),
                  content: MonthViewConfig(
                      lang: context.languageCode,
                      child: MonthInfoContainer(DateTime.utc(date.year, date.month, 1))));

              dialog.show(context).then((date) => Navigator.pop(context, date));
            }),
        ListTile(
            dense: true,
            title: Text('yearly'.tr(),
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            onTap: () {
              MonthViewConfig(
                      lang: context.languageCode,
                      sharing: false,
                      shortLabels: true,
                      highlightToday: false,
                      child: YearContainer(date))
                  .push(context)
                  .then((date) => Navigator.pop(context, date));
            })
      ]);
}
