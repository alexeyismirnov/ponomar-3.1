import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'dart:async';

import 'donations_other.dart';

class ChurchPage extends StatefulWidget {
  @override
  _ChurchPageState createState() => _ChurchPageState();
}

class _ChurchPageState extends State<ChurchPage> {
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> products = [];

  late bool isLoading, isAvailable;

  @override
  void initState() {
    super.initState();

    _subscription = InAppPurchase.instance.purchaseStream.listen(makePurchase, onDone: () {
      _subscription?.cancel();
      _subscription = null;
    });

    isLoading = true;
    isAvailable = false;

    Future.delayed(Duration.zero, () => postInit());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;

    super.dispose();
  }

  void postInit() {
    InAppPurchase.instance.isAvailable().then((isAvailable) {
      if (!isAvailable) throw ("not available");

      const Set<String> _kIds = {'donation1', 'donation2', 'donation3', 'donation4'};
      return InAppPurchase.instance.queryProductDetails(_kIds);
    }).then((response) {
      print("response ${response}");

      if (response.notFoundIDs.isNotEmpty) throw ("not found");

      isAvailable = true;

      products = List<ProductDetails>.from(response.productDetails);
      products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void makePurchase(purchases) {
    PurchaseDetails p = purchases[0];

    if (p.status == PurchaseStatus.pending) {}

    if (p.status == PurchaseStatus.purchased) {
      InAppPurchase.instance.completePurchase(p);

      AlertDialog(
        content: Text("donate_thanks".tr()),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ).show(context);
    }
  }

  Widget donationButton(ProductDetails product) => Center(
      child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 100, minWidth: 300, maxWidth: 300),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 7),
              child: Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  elevation: 5.0,
                  child: Center(
                      child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            InAppPurchase.instance.buyConsumable(
                                purchaseParam: PurchaseParam(productDetails: product));
                          },
                          child: Text("donate_button".tr(args: [product.price]),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline6)))))));

  List<Widget> getContent() {
    return [
      Row(mainAxisSize: MainAxisSize.max, children: [
        Expanded(
            child: Text("church_hk".tr(),
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6)),
      ]),
      const SizedBox(height: 20),
      Text("church_info".tr(), style: Theme.of(context).textTheme.subtitle1),
      const SizedBox(height: 10),
      Text("app_info".tr(), style: Theme.of(context).textTheme.subtitle1),
      const SizedBox(height: 10),
      SimpleCard(
          title: "install_church_app".tr(),
          image: "assets/images/church_icon.jpg",
          onTap: () =>
              StoreRedirect.redirect(androidAppId: "com.rlc.church", iOSAppId: "1566259967")),
      const SizedBox(height: 20),
      Text("please_make_donation".tr(), style: Theme.of(context).textTheme.subtitle1),
      if (isLoading) ...[
        Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: const Center(child: CircularProgressIndicator()))
      ],
      if (!isAvailable) ...[
        Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Center(child: const Text("network_error").tr()))
      ],
      if (products.isNotEmpty) ...[
        donationButton(products[0]),
        donationButton(products[1]),
        donationButton(products[2]),
        donationButton(products[3]),
      ],
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
                              style: Theme.of(context).textTheme.headline6))))))
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
