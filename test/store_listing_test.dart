import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponomar/store_listing.dart';

void main() {
  test('Apple platforms use the App Store', () {
    expect(usesAppleAppStore(TargetPlatform.iOS), isTrue);
    expect(usesAppleAppStore(TargetPlatform.macOS), isTrue);
    expect(usesAppleAppStore(TargetPlatform.android), isFalse);
  });

  test('AppGallery URIs prefer native listing then web search', () {
    final uris = appGalleryListingUris(packageId: 'com.frjonah.ponomar', appId: '');

    expect(uris, hasLength(2));
    expect(uris.first.toString(), 'appmarket://details?id=com.frjonah.ponomar');
    expect(uris.last.toString(), 'https://appgallery.huawei.com/search/com.frjonah.ponomar');
  });

  test('AppGallery web app URL is included when an app id is set', () {
    final uris = appGalleryListingUris(packageId: 'com.frjonah.ponomar', appId: 'C123456789');

    expect(uris.map((uri) => uri.toString()), [
      'appmarket://details?id=com.frjonah.ponomar',
      'https://appgallery.huawei.com/app/C123456789',
      'https://appgallery.huawei.com/search/com.frjonah.ponomar',
    ]);
  });

  test('App Store URIs are omitted until an Apple ID is set', () {
    expect(appStoreListingUris(appId: ''), isEmpty);
  });

  test('App Store URIs go to the write-review page when an Apple ID is set', () {
    expect(appStoreListingUris(appId: '123456789').map((uri) => uri.toString()), [
      'itms-apps://itunes.apple.com/app/id123456789?action=write-review',
      'https://apps.apple.com/app/id123456789',
    ]);
  });
}
