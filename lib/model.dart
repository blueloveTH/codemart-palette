import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_color_models/flutter_color_models.dart';
import 'package:palette/config.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:palette/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorMixModel {
  static ColorMixModel? _instance;
  static ColorMixModel get instance => _instance!;

  ColorMixModel._();

  static bool get initialized => _instance != null;

  static Future initialize() async {
    if (initialized) throw Exception("Already initialized");
    _instance = ColorMixModel._();

    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');
    await instance.loadJson(data);

    Timer.periodic(Duration(seconds: 25), (timer) async {
      await instance.saveJson();
      if (kDebugMode) {
        print("保存成功");
      }
    });
  }

  // saved fields
  List<Color> rgbs = cpntLabels.map((e) => Colors.black).toList();
  List<double> cachedPercents = cpntLabels.map((e) => 1.0).toList();
  Color A = Colors.black;
  Color B = Colors.black;
  List<Color> colorDB = [Colors.white, Colors.black];

  Color getColor(String key) {
    if (key == 'A') return A;
    if (key == 'B') return B;
    return rgbs[int.parse(key)];
  }

  List<int> chromaticAberration() {
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

  static final List<String> supportedAlgos = [
    'dual_annealing',
    'local',
    'shgo',
  ];

  Future getPercents() async {
    String payload = jsonEncode({
      "cmyk_cpnts": rgbs.map((e) => toCmyk01(e)).toList(),
      "cmyk_A": toCmyk01(A),
      "algo": supportedAlgos[2]
    });

    var resp = await http.post(Uri.parse('$apiUrl/solve_eq'),
        body: payload, headers: {"content-type": "application/json"});
    if (resp.statusCode != 200) {
      message("网络错误：${resp.statusCode}");
      return;
    }
    var data = jsonDecode(resp.body);
    cachedPercents = data['r.x'].cast<double>();
    B = CmykColor.fromList(
            data['mixed'].map((e) => e * 100).toList().cast<num>())
        .toColor();
  }

  Future<String> saveJson() async {
    String data = jsonEncode({
      "A": A.value,
      "B": B.value,
      "rgbs": rgbs.map((e) => e.value).toList(),
      "cachedPercents": cachedPercents,
      "colorDB": colorDB.map((e) => e.value).toList(),
    });

    var prefs = await SharedPreferences.getInstance();
    prefs.setString('data', data);
    return data;
  }

  Future loadJson(String? data) async {
    if (data == null) return;
    var json = jsonDecode(data);
    A = Color(json['A']);
    B = Color(json['B']);
    rgbs = json['rgbs'].map<Color>((e) => Color(e)).toList();
    cachedPercents = json['cachedPercents'].cast<double>();
    colorDB = json['colorDB'].map<Color>((e) => Color(e)).toList();
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
