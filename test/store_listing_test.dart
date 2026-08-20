import 'package:flutter_test/flutter_test.dart';
import 'package:ponomar/store_listing.dart';

void main() {
  test('AppGallery URIs prefer native listing then web search', () {
    final uris = appGalleryListingUris(packageId: 'com.rlc.ponomar', appId: '');

    expect(uris, hasLength(2));
    expect(uris.first.toString(), 'appmarket://details?id=com.rlc.ponomar');
    expect(uris.last.toString(), 'https://appgallery.huawei.com/search/com.rlc.ponomar');
  });

  test('AppGallery web app URL is included when an app id is set', () {
    final uris = appGalleryListingUris(packageId: 'com.rlc.ponomar', appId: 'C123456789');

    expect(uris.map((uri) => uri.toString()), [
      'appmarket://details?id=com.rlc.ponomar',
      'https://appgallery.huawei.com/app/C123456789',
      'https://appgallery.huawei.com/search/com.rlc.ponomar',
    ]);
  });
}
