// responsive_utils.dart

import 'package:flutter/widgets.dart';

double responsiveSize(BuildContext context, double size) {
 return MediaQuery.of(context).size.width * size;
}