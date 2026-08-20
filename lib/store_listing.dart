import 'package:flutter/foundation.dart';
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

/// Numeric Apple App Store ID (App Store Connect → App Information → Apple ID).
/// StoreKit in-app review works without this; the write-review URL needs it.
const String kAppStoreId = '';

bool usesAppleAppStore([TargetPlatform? platform]) {
  final target = platform ?? defaultTargetPlatform;
  return target == TargetPlatform.iOS || target == TargetPlatform.macOS;
}

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

List<Uri> appStoreListingUris({String appId = kAppStoreId}) {
  if (appId.isEmpty) {
    return [];
  }
  return [
    Uri.parse('itms-apps://itunes.apple.com/app/id$appId?action=write-review'),
    Uri.parse('https://apps.apple.com/app/id$appId'),
  ];
}

Future<bool> _launchFirstWorkingUri(List<Uri> uris) async {
  for (final uri in uris) {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return true;
      }
    } catch (_) {
      // Try the next URI.
    }
  }
  return false;
}

Future<bool> openAppGalleryListing() => _launchFirstWorkingUri(appGalleryListingUris());

Future<bool> openAppleAppStore() async {
  try {
    if ((await rateMyApp.isNativeReviewDialogSupported) ?? false) {
      await rateMyApp.launchNativeReviewDialog();
      return true;
    }
  } catch (_) {
    // Fall through to the App Store listing when StoreKit is unavailable.
  }
  return _launchFirstWorkingUri(appStoreListingUris());
}

/// Opens the store for the current platform: App Store on Apple, AppGallery on Android.
Future<bool> openStoreListing() {
  if (usesAppleAppStore()) {
    return openAppleAppStore();
  }
  return openAppGalleryListing();
}

/// Prompt used after several launches.
/// iOS/macOS: native StoreKit review sheet.
/// Android: in-app dialog that opens Huawei AppGallery (not Google Play).
Future<void> showAppRatingDialog(BuildContext context) {
  final onApple = usesAppleAppStore();
  return rateMyApp.showRateDialog(
    context,
    title: 'title'.tr(),
    message: 'please_rate'.tr(),
    ignoreNativeDialog: !onApple,
    listener: onApple
        ? null
        : (button) {
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
