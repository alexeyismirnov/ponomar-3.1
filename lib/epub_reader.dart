import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

Future<void> openEpubAsset(String filename) async {
  final path = filename.startsWith('assets/') ? filename : 'assets/epubs/$filename';
  try {
    await VocsyEpub.openAsset(path);
  } catch (e) {
    Fluttertoast.showToast(msg: 'network_error'.tr());
  }
}

void configureEpubReader(BuildContext context) {
  VocsyEpub.setConfig(
    themeColor: Theme.of(context).primaryColor,
    identifier: 'myBook',
    scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
    enableTts: false,
  );
}
