import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Material [Icons.open_in_full] / [Icons.close_fullscreen] — clearer than
/// « » for expand / restore of a side reader pane.
class PaneExpandButton extends StatelessWidget {
  final bool expanded;
  final VoidCallback onPressed;

  const PaneExpandButton({super.key, required this.expanded, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: expanded ? 'restore_pane'.tr() : 'expand_pane'.tr(),
      icon: Icon(expanded ? Icons.close_fullscreen : Icons.open_in_full, size: 22.0),
      onPressed: onPressed,
    );
  }
}

/// Animates [leading] panes away so [reader] can occupy the full width.
class ExpandablePanes extends StatelessWidget {
  final bool expanded;
  final List<Widget> leading;
  final Widget reader;
  final Duration duration;

  const ExpandablePanes({
    super.key,
    required this.expanded,
    required this.leading,
    required this.reader,
    this.duration = const Duration(milliseconds: 280),
  });

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ClipRect(
          child: AnimatedAlign(
              duration: duration,
              curve: Curves.easeInOutCubic,
              alignment: Alignment.centerLeft,
              widthFactor: expanded ? 0.0 : 1.0,
              child: Row(mainAxisSize: MainAxisSize.min, children: leading))),
      Expanded(child: reader),
    ]);
  }
}
