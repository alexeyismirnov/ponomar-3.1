import 'package:flutter/services.dart' show rootBundle;
import 'package:sprintf/sprintf.dart';
import 'package:flutter/cupertino.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:collection/collection.dart';
import 'package:sqflite/sqflite.dart';
import 'package:rate_my_app/rate_my_app.dart';

import 'dart:core';
import 'dart:async';
import 'dart:convert';

import 'book_model.dart';

String pCloudURL = "https://filedn.com/lUdNcEH0czFSe8uSnCeo29F";

class JSON {
  static late String calendar;
  static late String apostle, readingsJohn, gospelMatthew, gospelLuke, readingsLent;
  static late Function(String?) dateParser;

  static late String OldTestamentItems, OldTestamentFilenames;
  static late String NewTestamentItems, NewTestamentFilenames;

  static Map<String, Map<String, String>> bibleTrans = {};
  static Map<String, Map<String, String>> fastingComments = {};

  static Future load() async {
    calendar = await rootBundle.loadString("assets/calendar/calendar.json");
    apostle = await rootBundle.loadString("assets/calendar/ReadingApostle.json");
    readingsJohn = await rootBundle.loadString("assets/calendar/ReadingJohn.json");
    gospelMatthew = await rootBundle.loadString("assets/calendar/ReadingMatthew.json");
    gospelLuke = await rootBundle.loadString("assets/calendar/ReadingLuke.json");
    readingsLent = await rootBundle.loadString("assets/calendar/ReadingLent.json");

    OldTestamentItems = await rootBundle.loadString("assets/bible/OldTestamentItems.json");
    OldTestamentFilenames = await rootBundle.loadString("assets/bible/OldTestamentFilenames.json");
    NewTestamentItems = await rootBundle.loadString("assets/bible/NewTestamentItems.json");
    NewTestamentFilenames = await rootBundle.loadString("assets/bible/NewTestamentFilenames.json");

    bibleTrans['ru'] = Map<String, String>.from(
        jsonDecode(await rootBundle.loadString("assets/translations/ru/reading.json")));

    fastingComments['ru'] = Map<String, String>.from(
        jsonDecode(await rootBundle.loadString("assets/translations/ru/fasting.json")));
  }
}

extension StringFormatExtension on String {
  String format(var arguments) => sprintf(this, arguments);
}

extension DateTimeDiff on DateTime {
  int operator >>(DateTime other) => other.difference(this).inDays;
}

extension LocaleContext on BuildContext {
  String get languageCode => locale.toString().split("_").first;
  String get countryCode => locale.toString().split("_").last.toLowerCase();
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class DateChangedNotification extends Notification {
  late DateTime newDate;
  DateChangedNotification(this.newDate) : super();
}

class BookPositionNotification extends Notification {
  late BookPosition pos;
  BookPositionNotification(this.pos) : super();
}

class FontSizeChangedNotification extends Notification {
  FontSizeChangedNotification() : super();
}

extension ConfigParamExt on ConfigParam {
  static var fastingLevel;
  static var notifications;
  static var bookmarks;
  static var bibleLang;
}

Iterable<int> getRange(int low, int high, [int step = 1]) sync* {
  for (int i = low; i < high; i += step) {
    yield i;
  }
}

extension SqfliteExt on Sqflite {
  static String? firstStringValue(List<Map<String, Object?>> list) =>
      list.firstOrNull?.values.firstOrNull.toString();
}

RateMyApp rateMyApp = RateMyApp(
  preferencesPrefix: 'rate_orthodox_calendar',
  minDays: 3,
  minLaunches: 5,
  remindDays: 5,
  remindLaunches: 5,
);
