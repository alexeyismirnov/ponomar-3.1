import 'package:easy_localization/easy_localization.dart';
import 'package:quiver/iterables.dart';

import 'bible_model.dart';
import 'globals.dart';

enum PericopeFormat { text, widget }

class PericopeModel {
  final String lang;
  final String str;

  List<String> title = [];
  List<String> textContent = [];
  List<BibleUtil> buContent = [];

  PericopeModel(this.lang, this.str);

  Future<List<dynamic>> getPericope(PericopeFormat format) async {
    final pericope = str.trim().split(" ");

    final model1 = OldTestamentModel(lang);
    final model2 = NewTestamentModel(lang);

    final allItems = model1.items.expand((e) => e).toList()..addAll(model2.items.expand((e) => e));

    final allFilenames = model1.filenames.expand((e) => e).toList()
      ..addAll(model2.filenames.expand((e) => e));

    BibleUtil bu;

    for (final i in getRange(0, pericope.length, 2)) {
      var filename = pericope[i].toLowerCase();

      var text = <String>[];
      var buResult = BibleUtil(filename, lang, []);

      var chapter = 0;
      var bookName = "";

      if (lang == "ru" || lang == "cs") {
        bookName =
            "${allItems[allFilenames.indexOf(filename)].tr(gender: ConfigParamExt.bibleLang.val())} ${pericope[i + 1]}";
      } else {
        bookName = allItems[allFilenames.indexOf(filename)].tr();
      }

      title.add(bookName);

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
          buResult += bu;
        } else if (range[0].chapter != range[1].chapter) {
          bu = await BibleUtil.fetch(
              filename, lang, "chapter=${range[0].chapter} AND verse>=${range[0].verse}");

          text.add(bu.getText());
          buResult += bu;

          for (final chap in getRange(range[0].chapter + 1, range[1].chapter)) {
            bu = await BibleUtil.fetch(filename, lang, "chapter=$chap");

            text.add(bu.getText());
            buResult += bu;
          }

          bu = await BibleUtil.fetch(
              filename, lang, "chapter=${range[1].chapter} AND verse<=${range[1].verse}");

          text.add(bu.getText());
          buResult += bu;
        } else {
          bu = await BibleUtil.fetch(filename, lang,
              "chapter=${range[0].chapter} AND verse>=${range[0].verse} AND verse<=${range[1].verse}");

          text.add(bu.getText());
          buResult += bu;
        }
      }

      textContent.add(text.join(" "));
      buContent.add(buResult);
    }
    if (format == PericopeFormat.text) {
      return zip([title, textContent]).toList();
    } else {
      return zip([title, buContent]).toList();
    }
  }
}
