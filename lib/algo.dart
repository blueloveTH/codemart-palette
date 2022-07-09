import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_color_models/flutter_color_models.dart';
import 'package:palette/config.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class ColorMixModel {
  static ColorMixModel? _instance;

  static ColorMixModel get instance => _instance ??= ColorMixModel._();

  ColorMixModel._();

  List<Color> rgbs = cpntLabels.map((e) => Colors.black).toList();
  List<double> cachedPercents = cpntLabels.map((e) => 1.0).toList();
  Color A = Colors.black;
  Color B = Colors.black;

  Color getColor(String key) {
    if (key == 'A') return A;
    if (key == 'B') return B;
    return rgbs[int.parse(key)];
  }

  List<int> chromaticAberration() {
    /*var al = A.toLabColor();
    var bl = B.toLabColor();

    var _l = al.lightness - bl.lightness;
    var _a = al.a - bl.a;
    var _b = al.b - bl.b;*/
    return [B.red - A.red, B.green - A.green, B.blue - A.blue];
  }

  void setColor(String key, Color value) {
    if (key == 'A') {
      A = value;
    } else {
      rgbs[int.parse(key)] = value;
    }
  }

  static List<double> toCmyk01(Color c) {
    return c.toCmykColor().toList().map((e) => e * 0.01).toList();
  }

  Future getPercents() async {
    String payload = jsonEncode({
      "cmyk_cpnts": rgbs.map((e) => toCmyk01(e)).toList(),
      "cmyk_A": toCmyk01(A),
    });

    var resp = await http.post(Uri.parse('$apiUrl/solve_eq'),
        body: payload, headers: {"content-type": "application/json"});
    if (resp.statusCode != 200) throw Exception("网络错误：${resp.statusCode}");
    var data = jsonDecode(resp.body);
    cachedPercents = data['r.x'].cast<double>();
    B = CmykColor.fromList(
            data['mixed'].map((e) => e * 100).toList().cast<num>())
        .toColor();
  }

  /*
  int get cpntLength {
    assert(rgbs.length == percent.length);
    return rgbs.length;
  }

    List<double> getNormalizedPercent() {
    double sum = percent.reduce((a, b) => a + b);
    sum += 0.01; // avoid divide by zero error
    return percent.map((e) => e / sum).toList();
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
  }*/
}
