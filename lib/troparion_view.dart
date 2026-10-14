import 'package:flutter/material.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:easy_localization/easy_localization.dart';

import 'troparion_model.dart';
import 'book_page_single.dart';

/// Renders a list of troparia as content (no scaffold); shared by
/// [TroparionView] and the tablet dashboard reader pane.
class TroparionContent extends StatelessWidget {
  final List<Troparion> troparia;

  const TroparionContent(this.troparia);

  Widget buildTroparion(BuildContext context, Troparion t) {
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

  @override
  Widget build(BuildContext context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: troparia.map((t) => buildTroparion(context, t)).toList());
}

class TroparionView extends StatefulWidget {
  final List<Troparion> troparia;
  final bool showActions;

  const TroparionView(this.troparia, {this.showActions = true});

  @override
  TroparionViewState createState() => TroparionViewState();
}

class TroparionViewState extends State<TroparionView> {
  @override
  Widget build(BuildContext context) => BookPageSingle("troparia_kontakia".tr(),
      builder: () => TroparionContent(widget.troparia), showActions: widget.showActions);
}
