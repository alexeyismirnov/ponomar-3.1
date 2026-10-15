import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

enum DayViewLayout { phone, split, dashboard }

class LayoutInfo {
  /// Below this width the app keeps the classic phone UI.
  static const double splitBreakpoint = 600;

  /// Day view gains the month rail at this width.
  static const double dashboardBreakpoint = 1000;

  /// The app shell switches from BottomNavigationBar to NavigationRail.
  static const double railBreakpoint = 840;

  static bool isPortraitTablet(BuildContext context) =>
      isTabletDevice && MediaQuery.orientationOf(context) == Orientation.portrait;

  static DayViewLayout dayViewLayout(BuildContext context) {
    // Tablets in portrait use the single-column phone day view.
    if (isPortraitTablet(context)) return DayViewLayout.phone;

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

/// Closable banner suggesting landscape for a better tablet layout.
/// Dismissal is session-wide (shared across home / library tabs).
class LandscapeLayoutHintBanner extends StatefulWidget {
  const LandscapeLayoutHintBanner({super.key});

  @override
  State<LandscapeLayoutHintBanner> createState() => _LandscapeLayoutHintBannerState();
}

class _LandscapeLayoutHintBannerState extends State<LandscapeLayoutHintBanner> {
  static bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return MaterialBanner(
      leading: const Icon(Icons.screen_rotation_outlined),
      content: Text('landscape_layout_hint'.tr()),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() => _dismissed = true),
        ),
      ],
    );
  }
}
