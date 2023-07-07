import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:collection/collection.dart';

import 'book_model.dart';
import 'bible_model.dart';
import 'book_page_single.dart';
import 'globals.dart';

class BibleLangDialog extends StatelessWidget {
  final labels = ["Русский", "Церк.-слав."];
  final values = ["ru", "cs"];
  final lang;

  BibleLangDialog() : lang = ConfigParamExt.bibleLang.val();

  Widget _getListItem(BuildContext context, int index) => CheckboxListTile(
      title: Text(labels[index]),
      value: lang == values[index],
      onChanged: (_) {
        ConfigParamExt.bibleLang.set(values[index]);
        Navigator.of(context).pop(null);
      });

  @override
  Widget build(BuildContext context) => SelectorDialog(
      title: 'language',
      content: labels.mapIndexed((index, value) => _getListItem(context, index)).toList());
}

class BibleChapterView extends StatefulWidget {
  final BookPosition pos;
  final bool safeBottom;
  const BibleChapterView(this.pos, {required this.safeBottom});

  @override
  _BibleChapterViewState createState() => _BibleChapterViewState();
}

class _BibleChapterViewState extends State<BibleChapterView> {
  BookPosition get pos => widget.pos;

  bool ready = false;
  String title = "";
  late BibleUtil content;

  @override
  void initState() {
    super.initState();

    pos.model!.getTitle(pos).then((_title) {
      title = _title;
      return pos.model!.getContent(pos);
    }).then((_result) {
      content = _result;

      setState(() {
        ready = true;
      });
    });
  }

  Widget getContent() =>
      ready ? RichText(text: TextSpan(children: content.getTextSpan(context))) : Container();

  @override
  Widget build(BuildContext context) => BookPageSingle(title,
      bookmark: pos.model!.getBookmark(pos),
      builder: () => getContent(),
      safeBottom: widget.safeBottom);
}
