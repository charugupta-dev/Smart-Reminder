import 'package:flutter/material.dart';

/// Device type enum for responsive routing.
enum DeviceType { mobile, tablet, desktop }

/// Determines the device type based on screen width.
DeviceType getDeviceType(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return DeviceType.mobile;
  if (width < 1200) return DeviceType.tablet;
  return DeviceType.desktop;
}

/// A responsive scaffold that routes to the correct layout based on device type.
/// Each screen provides its own mobile, tablet, and desktop builders.
class ResponsiveScaffold extends StatelessWidget {
  final Widget Function(BuildContext context) mobileBuilder;
  final Widget Function(BuildContext context) tabletBuilder;
  final Widget Function(BuildContext context) desktopBuilder;

  const ResponsiveScaffold({
    super.key,
    required this.mobileBuilder,
    required this.tabletBuilder,
    required this.desktopBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobileBuilder(context);
      case DeviceType.tablet:
        return tabletBuilder(context);
      case DeviceType.desktop:
        return desktopBuilder(context);
    }
  }
}
