import 'package:flutter/material.dart';
import 'package:palette/algo.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text("调色盘"),
        actions: [
          TextButton(onPressed: () {}, child: Text("导入")),
          TextButton(onPressed: () {}, child: Text("导出")),
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
