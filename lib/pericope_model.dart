import 'package:flutter/material.dart';

import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:easy_localization/easy_localization.dart';

import 'bible_model.dart';
import 'globals.dart';

class PericopeModel {
  final String lang;
  final String str;
  final BuildContext? context;

  late Future initFuture;
  late double fontSize;
  late String family;

  List<String> title = [];
  List<String> textContent = [];
  List<Widget> widgetContent = [];

  PericopeModel(this.lang, this.str, [this.context]) {
    initFuture = getPericope();
  }

  Future getPericope() async {
    final pericope = str.trim().split(" ");

    if (context != null) {
      fontSize = ConfigParam.fontSize.val() + 2;
      family = Theme.of(context!).textTheme.bodyLarge!.fontFamily!;

      if (lang == "cs") {
        fontSize += 3.0;
        family = "Ponomar";
      }
    }

    final model1 = OldTestamentModel(lang);
    final model2 = NewTestamentModel(lang);

    final allItems = model1.items.expand((e) => e).toList()..addAll(model2.items.expand((e) => e));

    final allFilenames = model1.filenames.expand((e) => e).toList()
      ..addAll(model2.filenames.expand((e) => e));

    BibleUtil bu;

    for (final i in getRange(0, pericope.length, 2)) {
      List<String> text = [];
      List<TextSpan> span = [];

      var chapter = 0;
      var filename = pericope[i].toLowerCase();
      String bookName;

      if (lang == "ru" || lang == "cs") {
        bookName =
            "${allItems[allFilenames.indexOf(filename)].tr(gender: ConfigParamExt.bibleLang.val())} ${pericope[i + 1]}";
      } else {
        bookName = allItems[allFilenames.indexOf(filename)].tr();
      }

      title.add(bookName);

      if (context != null) {
        widgetContent.add(Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: RichText(
                text: TextSpan(
                    text: "$bookName\n",
                    style: Theme.of(context!).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold, fontFamily: family, fontSize: fontSize)),
                textAlign: TextAlign.center,
              ))
            ]));
      }

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

          text.add(bu.getText());
          if (context != null) span.addAll(bu.getTextSpan(context!));
        } else if (range[0].chapter != range[1].chapter) {
          bu = await BibleUtil.fetch(
              filename, lang, "chapter=${range[0].chapter} AND verse>=${range[0].verse}");

          text.add(bu.getText());
          if (context != null) span.addAll(bu.getTextSpan(context!));

          for (final chap in getRange(range[0].chapter + 1, range[1].chapter)) {
            bu = await BibleUtil.fetch(filename, lang, "chapter=$chap");
            text.add(bu.getText());
            if (context != null) span.addAll(bu.getTextSpan(context!));
          }

          bu = await BibleUtil.fetch(
              filename, lang, "chapter=${range[1].chapter} AND verse<=${range[1].verse}");

          text.add(bu.getText());
          if (context != null) span.addAll(bu.getTextSpan(context!));
        } else {
          bu = await BibleUtil.fetch(filename, lang,
              "chapter=${range[0].chapter} AND verse>=${range[0].verse} AND verse<=${range[1].verse}");

          text.add(bu.getText());
          if (context != null) span.addAll(bu.getTextSpan(context!));
        }
      }

      textContent.add(text.join(" "));

      if (context != null) {
        widgetContent.add(RichText(text: TextSpan(children: span)));
        widgetContent.add(const SizedBox(height: 20));
      }
    }
  }
}
