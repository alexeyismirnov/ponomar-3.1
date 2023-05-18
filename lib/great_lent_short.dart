import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'dart:math';

import 'story_model.dart';
import 'great_lent_full.dart';
import 'church_calendar.dart';
import 'globals.dart';

enum GreatLentDayMode { short, long, popup }

class GreatLentShortView extends StatefulWidget {
  final GreatLentDayMode mode;
  final DateTime date;

  const GreatLentShortView({required this.date, this.mode = GreatLentDayMode.long});

  @override
  _GreatLentShortViewState createState() => _GreatLentShortViewState();
}

class _GreatLentShortViewState extends State<GreatLentShortView> {
  late String image;
  late String header, title, description, footer;
  late DateFormat df;
  late StoryModel model;

  late String id;
  bool isAvailable = false;
  bool initialized = false;

  static const days = [
    "sundayOfPublicianAndPharisee",
    "sundayOfProdigalSon",
    "sundayOfDreadJudgement",
    "cheesefareSunday",
    "sunday1GreatLent",
    "sunday2GreatLent",
    "sunday3GreatLent",
    "sunday4GreatLent",
    "sunday5GreatLent",
    "palmSunday",
    "greatFriday",
    "pascha"
  ];

  @override
  void initState() {
    super.initState();

    final cal = Cal.fromDate(widget.date);

    for (final d in days) {
      if (cal.d(d) == widget.date) {
        id = d;
        isAvailable = true;
        break;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isAvailable) return;

    df = DateFormat.MMMMd(context.languageCode);
    model = StoryModel("great_lent.db");

    model.initFuture.then((_) {
      return model.getImage(id);
    }).then((String _image) {
      image = _image;
      var lang = context.countryCode;
      return model.getContent(id, lang);
    }).then((List<dynamic> snapshot) {
      header = snapshot[0]['text'] ?? '';
      title = snapshot[1]['text'] ?? '';
      description = snapshot[2]['text'] ?? '';
      footer = snapshot[3]['text'] ?? '';

      setState(() {
        initialized = true;
      });
    });
  }

  Widget buildShortView() {
    var content1 = Container(
      height: 80,
      child: Image.asset(
        "assets/images/$image",
        fit: BoxFit.contain,
      ),
    );

    var hh = (header.isNotEmpty && footer.isNotEmpty) ? "$header. " : header;

    var content2 = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(df.format(widget.date),
              textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (header.length + footer.length > 0) ...[
            const SizedBox(height: 10),
            Text("$hh$footer", style: Theme.of(context).textTheme.titleMedium),
          ],
        ]);

    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                contentPadding: const EdgeInsets.all(10),
                content: SizedBox(
                    width: min(MediaQuery.of(context).size.width, 400),
                    child: GreatLentShortView(date: widget.date, mode: GreatLentDayMode.popup)))
            .show(context),
        child: Row(children: [content1, const SizedBox(width: 15), Expanded(child: content2)]));
  }

  Widget buildLongView() {
    var content1 = Container(
        width: widget.mode == GreatLentDayMode.popup ? 100 : 130,
        child: Column(children: [
          Container(
            height: 100.0,
            child: Image.asset(
              "assets/images/$image",
              fit: BoxFit.contain,
            ),
          ),
        ]));

    var content2 = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: (header.isNotEmpty && footer.isEmpty)
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceAround,
        children: [
          if (header.isNotEmpty) ...[
            Text(header, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
          ],
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (footer.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(footer.toUpperCase(), style: Theme.of(context).textTheme.labelLarge)
          ]
        ]);

    var content3 = IntrinsicHeight(
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [content1, const SizedBox(width: 10), Expanded(child: content2)]));

    var content = Column(mainAxisSize: MainAxisSize.min, children: [
      content3,
      const SizedBox(height: 10),
      const SizedBox(width: 250, child: Divider(color: Colors.black)),
      const SizedBox(height: 10),
      Text(description, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 10),
    ]);

    if (widget.mode == GreatLentDayMode.long) {
      return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => GreatLentFullView(widget.date.year).push(context),
          child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CardWithTitle(title: "journey_to_pascha", content: content)));
    } else {
      return GestureDetector(
          behavior: HitTestBehavior.opaque, onTap: () => Navigator.pop(context), child: content);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized || !isAvailable) return Container();

    return (widget.mode == GreatLentDayMode.short) ? buildShortView() : buildLongView();
  }
}
