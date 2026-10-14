import 'package:flutter/material.dart';

enum DayViewLayout { phone, split, dashboard }

class LayoutInfo {
  /// Below this width the app keeps the classic phone UI.
  static const double splitBreakpoint = 600;

  /// Day view gains the month rail at this width.
  static const double dashboardBreakpoint = 1000;

  /// The app shell switches from BottomNavigationBar to NavigationRail.
  static const double railBreakpoint = 840;

  static DayViewLayout dayViewLayout(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= dashboardBreakpoint) return DayViewLayout.dashboard;
    if (w >= splitBreakpoint) return DayViewLayout.split;
    return DayViewLayout.phone;
  }

  static bool useNavigationRail(BuildContext context) =>
      MediaQuery.of(context).size.width >= railBreakpoint;

  /// Used in main() before runApp, where no BuildContext exists yet.
  static bool get isTabletDevice {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final shortest = view.physicalSize.shortestSide / view.devicePixelRatio;
    return shortest >= splitBreakpoint;
  }
}
