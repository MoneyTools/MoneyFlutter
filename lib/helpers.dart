import 'package:flutter/cupertino.dart';

import 'constants.dart';

numValueOrDefault(num? value, {num defaultValueIfNull = 0}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

intValueOrDefault(int? value, {int defaultValueIfNull = 0}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

isSmallWidth(BoxConstraints constraints,
    {num minWidth = Constants.narrowScreenWidthThreshold}) {
  if (constraints.maxWidth < minWidth) {
    return true;
  }
  return false;
}
