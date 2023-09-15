import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

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
  void didChangeDependencies() async {
    super.didChangeDependencies();

    String lang = context.countryCode;
    if (lang == "ru") lang = ConfigParamExt.bibleLang.val();

    final pericope = PericopeModel(lang, widget.str, context);
    await pericope.initFuture;

    content = List<Widget>.from(pericope.widgetContent);

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
              bibleFontButton: true,
              builder: () => PericopeView(
                  key: ValueKey(ConfigParamExt.bibleLang.val()),
                  currentReading[0])).push(context)));
}
