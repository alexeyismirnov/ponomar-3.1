import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:jiffy/jiffy.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

import 'globals.dart';
import 'calendar_appbar.dart';
import 'day_view.dart';
import 'bible_model.dart';
import 'firebase_config.dart';
import 'feast_notifications.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  int initialPage = 100000;

  late DateTime date;
  late PageController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PageController(initialPage: initialPage);
    setDate(DateTime.now());

    WidgetsBinding.instance.addObserver(this);

    Future.delayed(Duration.zero, () => postInit());
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (rateMyApp.shouldOpenDialog) {
      Future.delayed(
          Duration.zero,
          () =>
              rateMyApp.showRateDialog(context, title: "title".tr(), message: "please_rate".tr()));
    }
  }

  void postInit() async {
    await OldTestamentModel("ru").prepare();
    await NewTestamentModel("ru").prepare();

    await OldTestamentModel("cs").prepare();
    await NewTestamentModel("cs").prepare();

    await FirebaseConfig.requestPermissions();

    final year = DateTime.now().year;
    if (!ConfigParamExt.notifications.val().contains("$year")) {
      ConfigParamExt.notifications.set(["$year"]);

      FeastNotifications(date, context.languageCode).setup();
    }

    if (!ConfigParamExt.ver_1_4.val()) {
      ConfigParamExt.ver_1_4.set(true);
    }

    VocsyEpub.setConfig(
      themeColor: Theme.of(context).primaryColor,
      identifier: "myBook",
      scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
      enableTts: true,
    );

    await Jiffy.setLocale(context.languageCode);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        final dt = DateTime.now();

        if (date != DateTime.utc(dt.year, dt.month, dt.day)) {
          setDate(dt);
        }

        break;
      default:
        break;
    }
  }

  void setDate(DateTime d) {
    setState(() {
      date = DateTime.utc(d.year, d.month, d.day);
      if (_controller.hasClients) {
        initialPage = _controller.page!.round();
      }
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
              [CalendarAppbar()],
          body: Padding(
              padding: const EdgeInsets.all(10),
              child: PageView.builder(
                controller: _controller,
                itemBuilder: (BuildContext context, int index) {
                  final currentDate = date.add(Duration(days: index - initialPage));
                  return NotificationListener<Notification>(
                      onNotification: (n) {
                        if (n is DateChangedNotification) setDate(n.newDate);
                        return true;
                      },
                      child: DayView(key: ValueKey(currentDate), date: currentDate));
                },
              ))));
}
