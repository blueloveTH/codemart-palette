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

class CpntModel {
  bool enabled = true;
  Color color;
  double percent = 1.0;

  CpntModel(this.color);

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'color': color.value,
        'percent': percent,
      };

  CpntModel.fromJson(Map<String, dynamic> json)
      : enabled = json['enabled'],
        color = Color(json['color']),
        percent = json['percent'];
}

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
  List<CpntModel> rgbs = [
    for (int i = 0; i < 5; i++) CpntModel(Colors.black),
  ];

  Color A = Colors.black;
  Color B = Colors.black;
  List<double> scales = [1.0, 0.12, 0.08];
  List<Color> colorDB = [Colors.white, Colors.black];

  Color getColor(String key) {
    if (key == 'A') return A;
    if (key == 'B') return B;
    return rgbs[int.parse(key)].color;
  }

  List<int> chromaticAberration() {
    return [B.red - A.red, B.green - A.green, B.blue - A.blue];
  }

  void setColor(String key, Color value) {
    if (key == 'A') {
      A = value;
    } else {
      rgbs[int.parse(key)].color = value;
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

  Future getPercents({required int algoIndex}) async {
    if (rgbs.where((e) => e.enabled).length < 2) {
      message("至少要有两个选择的颜色");
      return;
    }

    String payload = jsonEncode({
      "cmyk_cpnts":
          rgbs.where((e) => e.enabled).map((e) => toCmyk01(e.color)).toList(),
      "cmyk_A": toCmyk01(A),
      "algo": supportedAlgos[algoIndex]
    });

    // print payload if debug mode
    if (kDebugMode) {
      print(payload);
    }

    var resp = await http.post(Uri.parse('$apiUrl/solve_eq'),
        body: payload, headers: {"content-type": "application/json"});
    if (resp.statusCode != 200) {
      message("网络错误：${resp.statusCode}");
      return;
    }
    var data = jsonDecode(resp.body);
    var rX = data['r.x'].cast<double>();

    for (int i = 0; i < rgbs.length; i++) {
      if (rgbs[i].enabled) {
        rgbs[i].percent = rX[i];
      } else {
        rgbs[i].percent = 0;
      }
    }
    B = CmykColor.fromList(
            data['mixed'].map((e) => e * 100).toList().cast<num>())
        .toColor();
  }

  static const double version = 3.2;

  Future<String> saveJson() async {
    String data = jsonEncode({
      "A": A.value,
      "B": B.value,
      "rgbs": rgbs,
      "scales": scales,
      "colorDB": colorDB.map((e) => e.value).toList(),
      "version": version,
    });

    var prefs = await SharedPreferences.getInstance();
    prefs.setString('data', data);
    return data;
  }

  Future loadJson(String? data) async {
    if (data == null) return;
    var json = jsonDecode(data);
    if (version != json['version']) {
      message("版本不匹配，无法加载");
      await SharedPreferences.getInstance().then((value) => value.clear());
      return;
    }
    A = Color(json['A']);
    B = Color(json['B']);
    scales = json['scales'].cast<double>();
    rgbs = (json['rgbs'] as List)
        .map<CpntModel>((e) => CpntModel.fromJson(e))
        .toList();
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
