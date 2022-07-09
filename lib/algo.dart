import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_color_models/flutter_color_models.dart';
import 'package:palette/config.dart';

class ColorMixModel {
  static ColorMixModel? _instance;

  static ColorMixModel get instance => _instance ??= ColorMixModel._();

  ColorMixModel._();

  List<Color> rgbs = cpntLabels.map((e) => Colors.black).toList();
  List<double> percent = cpntPercents;
  Color A = Colors.black;

  Color getColor(String key) {
    if (key == 'A') return ColorMixModel.instance.A;
    return rgbs[int.parse(key)];
  }

  void setColor(String key, Color value) {
    if (key == 'A') {
      A = value;
    } else {
      rgbs[int.parse(key)] = value;
    }
  }

  // 

  List<double> getNormalizedPercent() {
    double sum = percent.reduce((a, b) => a + b);
    sum += 0.01; // avoid divide by zero error
    return percent.map((e) => e / sum).toList();
  }

  int get cpntLength {
    assert(rgbs.length == percent.length);
    return rgbs.length;
  }

  RgbColor get mixedColor {
    List<double> normalizedPercent = getNormalizedPercent();

    num c = 0;
    num m = 0;
    num y = 0;
    num k = 0;

    for (int i = 0; i < cpntLength; i++) {
      CmykColor e = rgbs[i].toCmykColor();
      double p = normalizedPercent[i];
      c += e.cyan * p;
      m += e.magenta * p;
      y += e.yellow * p;
      k += e.black * p;
    }

    c = min(100, c);
    m = min(100, m);
    y = min(100, y);
    k = min(100, k);

    return CmykColor(c, m, y, k).toRgbColor();
  }
}
