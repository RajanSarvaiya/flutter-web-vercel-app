import 'package:flutter/material.dart';
import '../../app/config/app_config.dart';

enum DeviceType { mobile, tablet, desktop }

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < Breakpoints.mobile) return DeviceType.mobile;
    if (width < Breakpoints.tablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  static double contentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 1320;
    if (width > Breakpoints.tablet) return width - 80;
    if (width > Breakpoints.mobile) return width - 48;
    return width - 32;
  }

  static int gridColumns(BuildContext context) {
    final type = getDeviceType(context);
    switch (type) {
      case DeviceType.desktop:
        return 4;
      case DeviceType.tablet:
        return 2;
      case DeviceType.mobile:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = getDeviceType(context);
    switch (type) {
      case DeviceType.desktop:
        return desktop;
      case DeviceType.tablet:
        return tablet ?? desktop;
      case DeviceType.mobile:
        return mobile;
    }
  }
}
