import 'package:flutter/material.dart';

class ResponsiveUtils {
  final BuildContext context;

  ResponsiveUtils(this.context);

  double screenHeight() => MediaQuery.of(context).size.height;
  double screenWidth() => MediaQuery.of(context).size.width;
  double verticalPadding(double factor) => screenHeight() * factor;
  double horizontalPadding(double factor) => screenWidth() * factor;
  double responsiveSize(double factor) => screenHeight() * factor;
}
