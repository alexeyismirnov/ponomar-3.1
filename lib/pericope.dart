import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/config_param.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'bible_model.dart';
import 'book_page_single.dart';
import 'globals.dart';
import 'custom_list_tile.dart';

class Range {
  final int chapter, verse;
  Range(this.chapter, this.verse);
}

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
  void didChangeDependencies() async {
    super.didChangeDependencies();

    final lang = ConfigParamExt.bibleLang.val();
    double fontSize = ConfigParam.fontSize.val() + 2;
    String family = Theme.of(context).textTheme.bodyLarge!.fontFamily!;

    if (lang == "cs") {
      fontSize += 3.0;
      family = "Ponomar";
    }

    BibleUtil bu;
    final pericope = widget.str.trim().split(" ");

    final model1 = OldTestamentModel(lang);
    final model2 = NewTestamentModel(lang);

    final allItems = model1.items.expand((e) => e).toList()..addAll(model2.items.expand((e) => e));

    final allFilenames = model1.filenames.expand((e) => e).toList()
      ..addAll(model2.filenames.expand((e) => e));

    for (final i in getRange(0, pericope.length, 2)) {
      var chapter = 0;
      var filename = pericope[i].toLowerCase();
      var bookName =
          "${allItems[allFilenames.indexOf(filename)].tr(gender: ConfigParamExt.bibleLang.val())} ${pericope[i + 1]}";

      List<TextSpan> text = [];

      content.add(Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: RichText(
              text: TextSpan(
                  text: "$bookName\n",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold, fontFamily: family, fontSize: fontSize)),
              textAlign: TextAlign.center,
            ))
          ]));

      final arr2 = pericope[i + 1].split(",");

      for (final segment in arr2) {
        List<Range> range = [];
        final arr3 = segment.split("-");

        for (final offset in arr3) {
          final arr4 = offset.split(":");

          if (arr4.length == 1) {
            range.add(Range(chapter, int.parse(arr4[0])));
          } else {
            chapter = int.parse(arr4[0]);
            range.add(Range(chapter, int.parse(arr4[1])));
          }
        }

        if (range.length == 1) {
          bu = await BibleUtil.fetch(
              filename, lang, "chapter=${range[0].chapter} AND verse=${range[0].verse}");

          text.addAll(bu.getTextSpan(context));
        } else if (range[0].chapter != range[1].chapter) {
          bu = await BibleUtil.fetch(
              filename, lang, "chapter=${range[0].chapter} AND verse>=${range[0].verse}");

          text.addAll(bu.getTextSpan(context));

          for (final chap in getRange(range[0].chapter + 1, range[1].chapter)) {
            bu = await BibleUtil.fetch(filename, lang, "chapter=$chap");
            text.addAll(bu.getTextSpan(context));
          }

          bu = await BibleUtil.fetch(
              filename, lang, "chapter=${range[1].chapter} AND verse<=${range[1].verse}");

          text.addAll(bu.getTextSpan(context));
        } else {
          bu = await BibleUtil.fetch(filename, lang,
              "chapter=${range[0].chapter} AND verse>=${range[0].verse} AND verse<=${range[1].verse}");

          text.addAll(bu.getTextSpan(context));
        }
      }

      content.add(RichText(text: TextSpan(children: text)));
      content.add(const SizedBox(height: 20));
    }

    setState(() => ready = true);
  }

  @override
  Widget build(BuildContext context) => ready
      ? Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content)
      : Container();
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
    title = currentReading[0];
    subtitle = currentReading.length > 1 ? currentReading[1].trim().tr() : null;

    title = JSON.bibleTrans[context.countryCode]!.entries
        .fold(title, (String prev, e) => prev.replaceAll(e.key, e.value));
  }

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: CustomListTile(
          title: title,
          subtitle: subtitle,
          onTap: () => BookPageSingle("Gospel of the day".tr(),
              bibleFontButton: true,
              builder: () => PericopeView(
                  key: ValueKey(ConfigParamExt.bibleLang.val()),
                  currentReading[0])).push(context)));
}
