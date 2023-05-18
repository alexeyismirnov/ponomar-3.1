import 'package:flutter/material.dart';

import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

import 'book_model.dart';

class PopupComment extends StatelessWidget {
  final String text;

  const PopupComment(this.text);

  @override
  Widget build(BuildContext context) {
    double dialogW = context.isTablet ? 500 : 280;
    double dialogH = 300;

    return AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        contentPadding: const EdgeInsets.all(10.0),
        insetPadding: const EdgeInsets.all(0.0),
        content: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pop(context),
            child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: dialogW, minWidth: dialogW, maxHeight: dialogH),
                child: SingleChildScrollView(child: BookCellText(text)))));
  }
}

class BookCellText extends StatelessWidget {
  final String text;

  const BookCellText(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: ConfigParam.fontSize.val()));
}

class BookCellHTML extends StatelessWidget {
  final String _text;
  final BookModel model;
  const BookCellHTML(this._text, this.model);

  final svg = """
    <svg id="Layer_1"  viewBox="0 0 24 24" >
    <g transform="scale(0.5)">
    <path style="fill: red" clip-rule="evenodd" d="M37,47H11c-2.209,0-4-1.791-4-4V5c0-2.209,1.791-4,4-4h18.973  c0.002,0,0.005,0,0.007,0h0.02H30c0.32,0,0.593,0.161,0.776,0.395l9.829,9.829C40.84,11.407,41,11.68,41,12l0,0v0.021  c0,0.002,0,0.003,0,0.005V43C41,45.209,39.209,47,37,47z M31,4.381V11h6.619L31,4.381z M39,13h-9c-0.553,0-1-0.448-1-1V3H11  C9.896,3,9,3.896,9,5v38c0,1.104,0.896,2,2,2h26c1.104,0,2-0.896,2-2V13z M33,39H15c-0.553,0-1-0.447-1-1c0-0.552,0.447-1,1-1h18  c0.553,0,1,0.448,1,1C34,38.553,33.553,39,33,39z M33,31H15c-0.553,0-1-0.447-1-1c0-0.552,0.447-1,1-1h18c0.553,0,1,0.448,1,1  C34,30.553,33.553,31,33,31z M33,23H15c-0.553,0-1-0.447-1-1c0-0.552,0.447-1,1-1h18c0.553,0,1,0.448,1,1C34,22.553,33.553,23,33,23  z" fill-rule="evenodd"/>
    </g>
    </svg>
    """;

  @override
  Widget build(BuildContext context) {
    int fontSize = ConfigParam.fontSize.val().round();

    var text = _text;

    String css = """
        <style type='text/css'>
        body {font-size: ${fontSize}px;  }
        a { text-decoration: none; }
        .rubric { color: red; font-size: 90%; }
        .title { font-size: 110%; font-weight:bold; text-align: center  }
        .refrain { font-style: italic }
        .author { color: red; font-size: 110%; font-weight:bold; }
        </style>
        """;

    text = text.replaceAllMapped(RegExp(r'comment_(\d+)', caseSensitive: false),
        (Match m) => "&nbsp;<a href=\"comment://${m[1]}\">$svg</a>&nbsp;");

    return Html(
        data: css + text,
        onLinkTap: (String? url, Map<String, String> attributes, dom.Element? element) async {
          final match = RegExp(r'comment://(\d+)').firstMatch(url!)?.group(1);
          if (match != null) {
            final commentId = int.parse(match);
            final text = await model.getComment(commentId);

            PopupComment(text!).show(context);
          }
        });
  }
}
