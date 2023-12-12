import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'main_page.dart';
import 'library_page.dart';
import 'globals.dart';
import 'church_fasting.dart';
import 'saint_model.dart';
import 'icon_model.dart';
import 'church_page.dart';
import 'firebase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await GlobalPath.ensureInitialized();

  await FirebaseConfig.setup();

  await ConfigParam.initSharedParams(initFontSize: 22);
  ConfigParamExt.fastingLevel = ConfigParam<int>('fastingLevel', initValue: 0);
  ChurchFasting.fastingLevel = FastingLevel.values[ConfigParamExt.fastingLevel.val()];
  ConfigParamExt.notifications = ConfigParam<List<String>>('notifications', initValue: []);
  ConfigParamExt.bookmarks = ConfigParam<List<String>>('bookmarks', initValue: []);
  ConfigParamExt.bibleLang = ConfigParam<String>('bibleLang', initValue: "cs");
  ConfigParamExt.ver_1_3 = ConfigParam<bool>('ver_1_3', initValue: false);

  if (!ConfigParamExt.ver_1_3.val()) {
    await FirebaseConfig.flutterLocalNotificationsPlugin.cancelAll();
    ConfigParamExt.notifications.set(<String>[]);
  }

  await JSON.load();

  await SaintModel("ru").prepare();

  await rateMyApp.init();

  final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  final books = assetManifest.listAssets().where((string) => string.startsWith("assets/books/")).toList();

  for (final f in books) {
    await DB.prepare(path: f);
  }

  await IconModel.prepare();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(EasyLocalization(
      supportedLocales: const [Locale('ru', '')],
      path: 'ui,cal,reading,library',
      assetLoader: DirectoryAssetLoader(basePath: "assets/translations"),
      fallbackLocale: const Locale('ru', ''),
      startLocale: const Locale('ru', ''),
      child: RestartWidget(ContainerPage(tabs: [
        AnimatedTab(icon: const Icon(Icons.home), title: 'homepage', content: MainPage()),
        AnimatedTab(
            icon: const ImageIcon(
              AssetImage('assets/images/library.png'),
            ),
            title: 'library',
            content: LibraryPage()),
        AnimatedTab(
            icon: const ImageIcon(
              AssetImage('assets/images/cross.png'),
            ),
            title: 'about_us',
            content: ChurchPage()),
      ]))));
}
