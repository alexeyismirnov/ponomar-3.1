import 'package:flutter/material.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:easy_localization/easy_localization.dart';

import 'troparion_model.dart';
import 'book_page_single.dart';

class TroparionView extends StatefulWidget {
  final List<Troparion> troparia;
  final bool showActions;

  const TroparionView(this.troparia, {this.showActions = true});

  @override
  TroparionViewState createState() => TroparionViewState();
}

class TroparionViewState extends State<TroparionView> {
  Widget buildTroparion(Troparion t) {
    final fontSize = ConfigParam.fontSize.val();

    List<Widget> content = [];

    final glas = t.glas ?? "";
    var title = t.title;

    if (glas.isNotEmpty) title += ", $glas";

    content.add(RichText(
      text: TextSpan(
          text: title,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.bold, fontSize: fontSize + 2)),
      textAlign: TextAlign.center,
    ));

    content.add(const SizedBox(height: 20));

    content.add(RichText(
        text: TextSpan(children: [
      TextSpan(
          text: "${t.content}\n",
          style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: fontSize))
    ])));

    return Column(children: content);
  }

  Widget getContent() => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.troparia.map((t) => buildTroparion(t)).toList());

  @override
  Widget build(BuildContext context) => BookPageSingle("troparia_kontakia".tr(),
      builder: () => getContent(), showActions: widget.showActions);
}
