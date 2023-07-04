import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:jiffy/jiffy.dart';

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

    if (!ConfigParamExt.ver_1_3.val()) {
      ConfigParamExt.ver_1_3.set(true);

      final dialog = AlertDialog(
          contentPadding: const EdgeInsets.all(10.0),
          content: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                              child: Text('Православный календарь+ v1.3',
                                  style: Theme.of(context).textTheme.titleLarge))
                        ]),
                    const SizedBox(height: 20),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                              child: Text('В новой версии приложения расширен раздел Библиотека.',
                                  style: Theme.of(context).textTheme.bodyLarge))
                        ]),
                  ])),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300, padding: const EdgeInsets.all(10.0)),
              child: Text('ОК',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            )
          ]);
      dialog.show(context);
    }

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
    if (rateMyApp.shouldOpenDialog) {
      rateMyApp.showRateDialog(context, title: "title".tr(), message: "please_rate".tr());
    }

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
