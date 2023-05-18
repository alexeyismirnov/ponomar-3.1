import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final double padding;
  final bool reversed;

  CustomListTile(
      {required this.title,
      this.subtitle,
      required this.onTap,
      this.padding = 5,
      this.reversed = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
          padding: EdgeInsets.only(bottom: padding),
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: (subtitle?.length ?? 0) == 0
                        ? Text(title,
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.titleLarge)
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: reversed
                                ? <Widget>[
                                    Text(subtitle!,
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                            color: Theme.of(context).secondaryHeaderColor)),
                                    Text(title,
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context).textTheme.titleLarge),
                                  ]
                                : <Widget>[
                                    Text(title,
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context).textTheme.titleLarge),
                                    Text(subtitle!,
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                            color: Theme.of(context).secondaryHeaderColor)),
                                  ]))
              ])));
}
