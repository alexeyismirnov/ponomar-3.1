import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:url_launcher/url_launcher.dart';

import 'donations_other.dart';

class ChurchPage extends StatefulWidget {
  @override
  _ChurchPageState createState() => _ChurchPageState();
}

class _ChurchPageState extends State<ChurchPage> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> getContent() {
    return [
      Row(mainAxisSize: MainAxisSize.max, children: [
        Expanded(
            child: Text("church_hk".tr(),
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium)),
      ]),
      const SizedBox(height: 20),
      Text("church_info".tr(), style: Theme.of(context).textTheme.bodyMedium),
      Text("telegram_info".tr(), style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 20),
      SizedBox(
          height: 60.0,
          child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).cardTheme.color,
              ),
              icon: const Icon(Icons.telegram, size: 40.0),
              label: Text("open_telegram".tr(), style: Theme.of(context).textTheme.bodyMedium),
              onPressed: () {
                launchUrl(Uri.parse("http://t.me/ponomar_en_bot"),
                    mode: LaunchMode.externalNonBrowserApplication);
              })),
      const SizedBox(height: 20),
      Text("please_make_donation".tr(), style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 15),
      Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 100, minWidth: 300, maxWidth: 300),
              child: Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  elevation: 5.0,
                  child: Center(
                      child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => DonationsOtherView().push(context),
                          child: Text("other_donations".tr(),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium))))))
    ];
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: CustomScrollView(slivers: <Widget>[
                SliverPadding(
                    padding: const EdgeInsets.all(15),
                    sliver: SliverList(delegate: SliverChildListDelegate(getContent())))
              ]))));
}
