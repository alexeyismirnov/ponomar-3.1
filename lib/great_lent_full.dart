import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'package:html2md/html2md.dart';

import 'great_lent_short.dart';
import 'church_calendar.dart';
import 'story_model.dart';

class GreatLentFullView extends StatefulWidget {
  final int year;
  const GreatLentFullView(this.year);

  @override
  _GreatLentFullViewState createState() => _GreatLentFullViewState();
}

class _GreatLentFullViewState extends State<GreatLentFullView> {
  bool initialized = false;
  late String text;
  late StoryModel model;

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

  late Cal cal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    cal = Cal.fromDate(DateTime.utc(widget.year, 1, 1));
    model = StoryModel("great_lent.db");

    model.initFuture.then((_) {
      var lang = context.locale.toString().split("_").last.toLowerCase();
      return model.getContent("greatLent", lang);
    }).then((List<dynamic> snapshot) {
      text = convert(snapshot[0]['text'] ?? '', ignore: ['img']).trim();

      setState(() {
        initialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SafeArea(
        top: false,
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
                child: Column(
                    children: days
                            .map<Widget>((item) => Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      GreatLentShortView(
                                          date: cal.d(item), mode: GreatLentDayMode.short),
                                      const Divider(color: Colors.black),
                                    ]))
                            .toList() +
                        (!initialized
                            ? [Container()]
                            : [
                                MarkdownBody(
                                    data: text,
                                    extensionSet: md.ExtensionSet.gitHubFlavored,
                                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                                        .copyWith(textScaleFactor: 1.5))
                              ])))));

    return Container(
        decoration: AppTheme.bg_decor_2() ?? BoxDecoration(color: Theme.of(context).canvasColor),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
                centerTitle: true,
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                title: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: const Text("journey_to_pascha").tr())),
            body: content));
  }
}
