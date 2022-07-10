import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette/message.dart';
import 'package:palette/model.dart';
import 'package:palette/config.dart';
import 'package:palette/cpnt.dart';
import 'package:palette/loading.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Color colorA = Colors.white;

  @override
  void initState() {
    super.initState();

    ColorMixModel.initialize().then((value) {
      setState(() {});
    });
  }

  Widget buildColorCpnts(BuildContext context) {
    double size = 64;

    return Column(
      children: [
        for (int i = 0; i < cpntLabels.length; i++)
          Row(
            children: [
              ColorCpnt(
                i.toString(),
                size: size,
                label: cpntLabels[i],
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                height: size * 0.8,
                width: size * 1.5,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Text(
                  (ColorMixModel.instance.cachedPercents[i] * 100)
                          .toStringAsFixed(2) +
                      " %",
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget buildMixedColor(BuildContext context) {
    return Column(
      children: [
        ColorCpnt(
          "B",
          size: 100,
          label: "B",
          enabled: false,
        ),
        Text("RGB色差：\n" +
            ColorMixModel.instance.chromaticAberration().toString()),
      ],
    );
  }

  Widget buildTargetColor(BuildContext context) {
    return Column(
      children: [
        ColorCpnt(
          "A",
          size: 100,
          label: "A",
        ),
        ElevatedButton(
            onPressed: () async {
              showLoadingDialog(context);
              try {
                await ColorMixModel.instance.getPercents();
                setState(() {});
              } finally {
                Navigator.pop(context);
              }
            },
            child: Text("计算配比")),
        buildMixedColor(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!ColorMixModel.initialized) return CircularProgressIndicator();
    return Scaffold(
      appBar: AppBar(
        title: Text("调色盘"),
        actions: [
          TextButton(
              onPressed: () async {
                var value = await Clipboard.getData("text/plain");
                if (value == null) {
                  message("剪贴板没有数据");
                  return;
                }
                await ColorMixModel.instance.loadJson(value.text);
                message("导入成功");
                setState(() {});
              },
              child: Text("导入")),
          TextButton(
              onPressed: () async {
                String data = await ColorMixModel.instance.saveJson();
                Clipboard.setData(ClipboardData(text: data));
                message("数据已复制到剪贴板");
              },
              child: Text("导出")),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildColorCpnts(context),
                  buildTargetColor(context),
                ]),
          ],
        ),
      ),
    );
  }
}
