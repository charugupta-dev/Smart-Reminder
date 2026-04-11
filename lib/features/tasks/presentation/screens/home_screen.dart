import 'package:flutter/material.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import 'mobile_home_screen.dart';
import 'tablet_home_screen.dart';
import 'desktop_home_screen.dart';

/// Entry point router for the Home/Tasks screen.
/// Routes to the correct device-specific UI based on screen width.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      mobileBuilder: (_) => const MobileHomeScreen(),
      tabletBuilder: (_) => const TabletHomeScreen(),
      desktopBuilder: (_) => const DesktopHomeScreen(),
    );
  }
}
