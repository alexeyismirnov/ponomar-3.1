import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';

import 'globals.dart';

/// Android application id used by AppGallery deep links.
const String kAndroidPackageId = 'com.rlc.ponomar';

/// Huawei AppGallery app ID (`C` followed by digits) once the listing exists.
/// The native `appmarket://` deep link works from the package name alone.
const String kHuaweiAppGalleryAppId = '';

/// Candidate URIs for the AppGallery listing, native app first then web.
List<Uri> appGalleryListingUris({
  String packageId = kAndroidPackageId,
  String appId = kHuaweiAppGalleryAppId,
}) {
  return [
    Uri.parse('appmarket://details?id=$packageId'),
    if (appId.isNotEmpty) Uri.parse('https://appgallery.huawei.com/app/$appId'),
    Uri.parse('https://appgallery.huawei.com/search/${Uri.encodeComponent(packageId)}'),
  ];
}

Future<bool> openAppGalleryListing() async {
  for (final uri in appGalleryListingUris()) {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return true;
      }
    } catch (_) {
      // Try the next URI (AppGallery app may be missing on this device).
    }
  }
  return false;
}

/// Prompt used after several launches. Skips Google Play in-app review and
/// opens Huawei AppGallery when the user chooses to rate.
Future<void> showAppRatingDialog(BuildContext context) {
  return rateMyApp.showRateDialog(
    context,
    title: 'title'.tr(),
    message: 'please_rate'.tr(),
    ignoreNativeDialog: true,
    listener: (button) {
      if (button != RateMyAppDialogButton.rate) {
        return true;
      }
      rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
      Navigator.pop(context, RateMyAppDialogButton.rate);
      openAppGalleryListing();
      return false;
    },
  );
}
