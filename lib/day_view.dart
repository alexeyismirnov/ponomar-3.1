import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'dart:math';

import 'church_day.dart';
import 'church_calendar.dart';
import 'church_fasting.dart';
import 'church_reading.dart';
import 'globals.dart';
import 'pericope.dart';
import 'saint_model.dart';
import 'icon_model.dart';
import 'feofan.dart';
import 'synaxarion.dart';
import 'calendar_selector.dart';
import 'layout_info.dart';
import 'book_cell.dart';
import 'great_lent_short.dart';
import 'saints_lives.dart';
import 'troparion_model.dart';

class _FeastWidget extends StatelessWidget {
  final ChurchDay d;
  final TextStyle? style;
  final bool translate;

  const _FeastWidget(this.d, {this.style, this.translate = true});

  @override
  Widget build(BuildContext context) {
    if (d.type == FeastType.great) {
      return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(children: [
            SvgPicture.asset("assets/images/great.svg", height: 30),
            const SizedBox(width: 10),
            Expanded(
                child: Text(translate ? d.name.tr() : d.name,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.red)))
          ]));
    } else {
      var textStyle =
          style ?? Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500);

      if (d.type.name != "none") {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
            child: RichText(
                text: TextSpan(children: [
              WidgetSpan(
                  child: SvgPicture.asset("assets/images/${d.type.name.toLowerCase()}.svg",
                      height: 15)),
              TextSpan(text: translate ? d.name.tr() : d.name, style: textStyle)
            ])));
      } else {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
            child: Text(translate ? d.name.tr() : d.name, style: textStyle));
      }
    }
  }
}

/// Date row. Tappable (opens the calendar selector) except on the tablet
/// dashboard, where the month rail already provides today/year navigation.
class DateHeader extends StatelessWidget {
  final DateTime date;

  DateTime get dateOld => date.subtract(const Duration(days: 13));

  const DateHeader(this.date);

  @override
  Widget build(BuildContext context) {
    final df1 = DateFormat.yMMMMEEEEd(context.languageCode);
    final df2 = DateFormat.yMMMMd(context.languageCode);

    final dates = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AutoSizeText(df1.format(date).capitalize(),
              textAlign: TextAlign.left,
              maxLines: 1,
              minFontSize: 5,
              style: Theme.of(context).textTheme.titleLarge),
          AutoSizeText(df2.format(dateOld) + " " + "old_style".tr(),
              textAlign: TextAlign.left,
              maxLines: 1,
              minFontSize: 5,
              style: Theme.of(context).textTheme.titleMedium),
        ]);

    if (LayoutInfo.dayViewLayout(context) == DayViewLayout.dashboard) {
      return dates;
    }

    return GestureDetector(
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.calendar_today, size: 30.0),
              const SizedBox(width: 10),
              Expanded(child: dates)
            ]),
        onTap: () {
          CalendarSelector(date).show(context).then((newDate) {
            if (newDate != null) {
              DateChangedNotification(newDate).dispatch(context);
            }
          });
        });
  }
}

/// Week/tone description line + feast rows.
class DayDescription extends StatelessWidget {
  final DateTime date;

  const DayDescription(this.date);

  @override
  Widget build(BuildContext context) {
    final cal = Cal.fromDate(date);

    var list = [cal.getWeekDescription(date), cal.getToneDescription(date)];
    var weekDescr = list.whereType<String>().join('; ');
    var dayDescr = cal.getDayDescription(date);

    List<Widget> feastWidgets = dayDescr.map((d) => _FeastWidget(d)).toList();

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (weekDescr.isNotEmpty
                ? <Widget>[Text(weekDescr, style: Theme.of(context).textTheme.titleMedium)]
                : <Widget>[]) +
            feastWidgets);
  }
}

/// Fasting row with icon and optional comment popup.
class FastingRow extends StatelessWidget {
  final DateTime date;

  const FastingRow(this.date);

  @override
  Widget build(BuildContext context) => FutureBuilder<FastingModel>(
      future: ChurchFasting.forDate(date, context.countryCode),
      builder: (BuildContext context, AsyncSnapshot<FastingModel> snapshot) {
        if (snapshot.hasData) {
          final fasting = snapshot.data!;

          List<InlineSpan> spans = [
            TextSpan(
                text: fasting.description.tr() + "  ",
                style: Theme.of(context).textTheme.titleMedium)
          ];

          String? comment = JSON.fastingComments[context.countryCode]![fasting.description];

          if (comment != null) {
            spans.add(const WidgetSpan(
              child: Icon(Icons.article_outlined, size: 25.0, color: Colors.red),
            ));
          }

          return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (comment != null) PopupComment(comment).show(context);
              },
              child: Row(children: [
                SvgPicture.asset("assets/images/${fasting.type.icon}", height: 30),
                const SizedBox(width: 10),
                Expanded(child: RichText(text: TextSpan(children: spans)))
              ]));
        } else {
          return Container();
        }
      });
}

/// Paged strip of saint icons for the day.
class IconGallery extends StatefulWidget {
  final DateTime date;

  const IconGallery(this.date);

  @override
  _IconGalleryState createState() => _IconGalleryState();
}

class _IconGalleryState extends State<IconGallery> {
  late List<SaintIcon> icons = [];
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<SaintIcon>>(
      future: IconModel.fetch(widget.date),
      builder: (BuildContext context, AsyncSnapshot<List<SaintIcon>> snapshot) {
        if (snapshot.hasData) {
          if (icons.isEmpty) {
            icons = List<SaintIcon>.from(snapshot.data!);
          }

          return LayoutBuilder(builder: (context, constraints) {
            const itemWidth = 100;
            const padding = 10;

            final pageSize =
                max(1, (constraints.maxWidth - 4 * padding) ~/ (itemWidth + 10));

            Widget _iconPage(int page) {
              final newItems =
                  icons.sublist(page * pageSize, min((page + 1) * pageSize, icons.length));

              final pageNotFull = page > 0 && (page + 1) * pageSize > icons.length;

              return Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment:
                      pageNotFull ? MainAxisAlignment.start : MainAxisAlignment.spaceAround,
                  children: [
                    if (!pageNotFull) ...[const Spacer()],
                    ...newItems
                        .map<Widget>((s) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                            child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (context.languageCode == 'ru') {
                                    PopupComment(s.name).show(context);
                                  }
                                },
                                child: Image.asset(
                                  'assets/icons/${s.id}.jpg',
                                  height: 110.0,
                                  fit: BoxFit.contain,
                                ))))
                        .toList(),
                    if (!pageNotFull) ...[const Spacer()],
                  ]);
            }

            return Container(
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                height: 120.0,
                child: PageView.builder(
                    controller: _controller,
                    itemCount: (icons.length - 1) ~/ pageSize + 1,
                    itemBuilder: (BuildContext context, int index) => _iconPage(index)));
          });
        } else {
          return Container();
        }
      });
}

/// "Reading of the day" card: Apostle/Gospel, synaxarion, feofan, lives, troparia.
class ReadingsCard extends StatelessWidget {
  final DateTime date;

  const ReadingsCard(this.date);

  @override
  Widget build(BuildContext context) {
    final reading = ChurchReading.forDate(date);
    List<Widget> content = [];

    for (final r in reading) {
      content.add(ReadingView(r));
    }

    content.add(SynaxarionView(date));

    if (context.languageCode == "en") {
      content.add(FeofanView(date));
      content.add(SaintsLivesView(date));

      content.add(const SizedBox(height: 5));
      content.add(TroparionWidget(date));
    }

    return CardWithTitle(
        title: "Reading of the day",
        content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content));
  }
}

/// "Memory of saints" card.
class SaintsCard extends StatefulWidget {
  final DateTime date;

  const SaintsCard(this.date);

  @override
  _SaintsCardState createState() => _SaintsCardState();
}

class _SaintsCardState extends State<SaintsCard> {
  late SaintModel saints;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    saints = SaintModel(context.countryCode);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Saint>>(
      future: saints.fetch(widget.date),
      builder: (BuildContext context, AsyncSnapshot<List<Saint>> snapshot) {
        if (snapshot.hasData) {
          return CardWithTitle(
              title: "Memory of saints",
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List<ChurchDay>.from(snapshot.data!)
                      .map((s) => _FeastWidget(s,
                          style: Theme.of(context).textTheme.titleMedium, translate: false))
                      .toList()));
        } else {
          return Container();
        }
      });
}

/// The header card grouping date, description, fasting and icons.
class DayHeaderCard extends StatelessWidget {
  final DateTime date;

  const DayHeaderCard(this.date);

  @override
  Widget build(BuildContext context) => CardWithTitle(
      title: "",
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateHeader(date),
            const SizedBox(height: 10),
            DayDescription(date),
            const SizedBox(height: 10),
            FastingRow(date),
            const SizedBox(height: 10),
            IconGallery(date)
          ]));
}

/// All day-view sections in order; shared by the phone [DayView] and the
/// tablet dashboard summary pane.
List<Widget> dayViewSections(DateTime date) => [
      DayHeaderCard(date),
      GreatLentShortView(date: date),
      const SizedBox(height: 10),
      ReadingsCard(date),
      const SizedBox(height: 10),
      SaintsCard(date)
    ];

class DayView extends StatelessWidget {
  final DateTime date;

  const DayView({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: dayViewSections(date)));
  }
}
