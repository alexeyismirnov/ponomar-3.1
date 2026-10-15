import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

class DonationsOtherView extends StatelessWidget {
  /// Embedded mode renders just the donations list (with a title) so it can
  /// live inside the About Us tab as a side column on tablets in landscape.
  final bool embedded;

  const DonationsOtherView({super.key, this.embedded = false});

  final bank_account =
      "Orthodox Brotherhood of Apostles Saints Peter and Paul; Account # 514—40−66582—7, The Bank of East Asia Ltd., 10 Des Voeux Road, Central Hong Kong, Swift BEASHKHH, bank code 015, branch code 5";

  final paypal = "church@orthodoxy.hk";
  final alipay = "+852 94385021";
  final wechat = "frdionisy";
  final bitcoin = "3QzG3dooTfQ7fGctwirZJyJcqxMF3YSoKR";
  final tng = "6101-8019-2213-7852";

  Widget _listItem(
    BuildContext context,
    String title,
    String subtitle,
  ) => Column(
    children: [
      ListTile(
        dense: true,
        contentPadding: const EdgeInsets.all(0),
        trailing: TextButton(
          child: const Icon(Icons.file_copy_outlined, size: 40),
          onPressed: () {
            Fluttertoast.showToast(
              msg: "copied_to_clipboard".tr(),
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.lightGreen,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            Clipboard.setData(ClipboardData(text: subtitle));
          },
        ),
        title: Text(title.tr(), style: Theme.of(context).textTheme.bodyMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ),
      const Divider(thickness: 2),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      shrinkWrap: true,
      children: [
        _listItem(context, "bank_account", bank_account),
        _listItem(context, "paypal", paypal),
        _listItem(context, "alipay", alipay),
        _listItem(context, "wechat", wechat),
        _listItem(context, "bitcoin", bitcoin),
        _listItem(context, "tng", tng),
      ],
    );

    if (embedded) {
      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                "donate".tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                child: list,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration:
          AppTheme.bg_decor_2() ??
          BoxDecoration(color: Theme.of(context).canvasColor),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: const Text("donate").tr(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: list,
        ),
      ),
    );
  }
}
