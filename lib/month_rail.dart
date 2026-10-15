import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'church_calendar.dart';
import 'church_day.dart';
import 'globals.dart';
import 'month_info_container.dart';
import 'year_calendar.dart';

/// Left rail of the tablet day dashboard: the real month grid with fasting
/// colors, month chevrons, a ring on the selected date, plus "today" and
/// "year calendar" buttons. When the selected day falls in a major feast's
/// forefeast / afterfeast / apodosis, a clickable link to that feast is shown.
class MonthRail extends StatelessWidget {
  final DateTime date;

  const MonthRail({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final monthStart = DateTime.utc(date.year, date.month, 1);
    final periods = Cal.fromDate(date).getFeastPeriods(date);

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
          Row(children: [
            Expanded(
                child: TextButton.icon(
                    onPressed: () {
                      final now = DateTime.now();
                      DateChangedNotification(DateTime.utc(now.year, now.month, now.day))
                          .dispatch(context);
                    },
                    icon: const Icon(Icons.today_outlined, size: 20.0),
                    label: Text('today'.tr(), style: Theme.of(context).textTheme.titleMedium))),
            Expanded(
                child: TextButton.icon(
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
                    label: Text('yearly'.tr(), style: Theme.of(context).textTheme.titleMedium)))
          ]),
          if (periods.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final period in periods) _FeastPeriodEntry(period),
          ],
        ]));
  }
}

/// Forefeast / afterfeast / apodosis row. The feast name is a tappable link that
/// jumps the dashboard to that feast's day (middle pane).
class _FeastPeriodEntry extends StatefulWidget {
  final FeastPeriod period;

  const _FeastPeriodEntry(this.period);

  @override
  State<_FeastPeriodEntry> createState() => _FeastPeriodEntryState();
}

class _FeastPeriodEntryState extends State<_FeastPeriodEntry> {
  late final TapGestureRecognizer _tap = TapGestureRecognizer();

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tap.onTap = () => DateChangedNotification(widget.period.feastDate).dispatch(context);

    final template = '${widget.period.kind}_of'.tr();
    final feastName = widget.period.feast.tr();
    final parts = template.split('%s');

    final baseStyle = Theme.of(context).textTheme.titleSmall!;
    final linkStyle = baseStyle.copyWith(
        color: Colors.red,
        decoration: TextDecoration.underline,
        decorationColor: Colors.red,
        fontWeight: FontWeight.w600);

    return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text.rich(
            TextSpan(style: baseStyle, children: [
              if (parts.isNotEmpty && parts[0].isNotEmpty) TextSpan(text: parts[0]),
              TextSpan(text: feastName, style: linkStyle, recognizer: _tap),
              if (parts.length > 1 && parts[1].isNotEmpty) TextSpan(text: parts[1]),
            ])));
  }
}
