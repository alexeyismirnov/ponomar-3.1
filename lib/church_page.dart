import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:url_launcher/url_launcher.dart';

import 'donations_other.dart';
import 'layout_info.dart';

Future<void> openTelegramBot(String botUsername) async {
  final uris = [
    Uri.parse('tg://resolve?domain=$botUsername'),
    Uri.parse('https://t.me/$botUsername'),
  ];

  for (final uri in uris) {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {
      // Try the next URI scheme.
    }
  }
}

class ChurchPage extends StatefulWidget {
  @override
  _ChurchPageState createState() => _ChurchPageState();
}

class _ChurchPageState extends State<ChurchPage> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> getContent({bool includeDonations = true}) {
    return [
      Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Text(
              "church_hk".tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
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
          label: Text(
            "open_telegram".tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          onPressed: () => openTelegramBot('ponomar_ru_bot'),
        ),
      ),
      const SizedBox(height: 20),
      Text(
        "please_make_donation".tr(),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      if (includeDonations) ...[
        const SizedBox(height: 15),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 100,
              minWidth: 300,
              maxWidth: 300,
            ),
            child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              elevation: 5.0,
              child: Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => DonationsOtherView().push(context),
                  child: Text(
                    "other_donations".tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Tablets in landscape: church info on the left, donation methods on the
    // right (the "other ways to donate" button is not needed there).
    if (LayoutInfo.isTabletDevice &&
        MediaQuery.orientationOf(context) == Orientation.landscape) {
      return SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverPadding(
                        padding: const EdgeInsets.all(15),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            getContent(includeDonations: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: DonationsOtherView(embedded: true)),
          ],
        ),
      );
    }

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(15),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(getContent()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
