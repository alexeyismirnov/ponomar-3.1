import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'bible_model.dart';
import 'book_page_single.dart';
import 'globals.dart';
import 'custom_list_tile.dart';
import 'pericope_model.dart';

class PericopeView extends StatefulWidget {
  final String str;
  const PericopeView(this.str, {super.key});

  @override
  _PericopeViewState createState() => _PericopeViewState();
}

class _PericopeViewState extends State<PericopeView> {
  bool ready = false;
  List<Widget> content = [];

  @override
  Widget build(BuildContext context) {
    String lang = context.countryCode;
    if (lang == "ru") lang = ConfigParamExt.bibleLang.val();

    double fontSize = ConfigParam.fontSize.val() + 2;
    String family = Theme.of(context).textTheme.bodyLarge!.fontFamily!;

    if (lang == "cs") {
      fontSize += 3.0;
      family = "Ponomar";
    }

    return FutureBuilder<List<dynamic>>(
        future: PericopeModel(lang, widget.str).getPericope(PericopeFormat.widget),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("network error"));
          }
          if (snapshot.hasData) {
            List<Widget> content = [];

            for (List<dynamic> values in snapshot.data!) {
              var title = values[0] as String;
              content.add(Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: RichText(
                      text: TextSpan(
                          text: "$title\n",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold, fontFamily: family, fontSize: fontSize)),
                      textAlign: TextAlign.center,
                    ))
                  ]));

              var bu = values[1] as BibleUtil;
              content.add(RichText(text: TextSpan(children: bu.getTextSpan(context))));
            }

            return SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: content));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

class ReadingView extends StatefulWidget {
  final String r;
  const ReadingView(this.r);

  @override
  _ReadingViewState createState() => _ReadingViewState();
}

class _ReadingViewState extends State<ReadingView> {
  late String title;
  late String? subtitle;
  late List<String> currentReading;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    currentReading = widget.r.split("#");
    title = JSON.translateReading(currentReading[0], lang: context.countryCode);
    subtitle = currentReading.length > 1 ? currentReading[1].trim().tr() : null;
  }

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: CustomListTile(
          title: title,
          subtitle: subtitle,
          onTap: () => BookPageSingle("Gospel of the day".tr(),
              bibleFontButton: (context.languageCode == "ru"),
              builder: () => PericopeView(
                  key: ValueKey(ConfigParamExt.bibleLang.val()),
                  currentReading[0])).push(context)));
}
