import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette/message.dart';
import 'package:palette/model.dart';
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

  Widget buildPercent(double size, int i, double scale) {
    return Expanded(
      child: Container(
        height: size * 0.8,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(2),
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        child: Text(
          (ColorMixModel.instance.rgbs[i].percent * 100 * scale)
                  .toStringAsFixed(2) +
              " %",
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget buildScales(double size) {
    return Row(
      children: [
        Row(
          children: [
            Checkbox(
              value: ColorMixModel.instance.rgbs
                  .every((element) => element.enabled),
              onChanged: (_) {
                bool val = ColorMixModel.instance.rgbs
                    .every((element) => element.enabled);
                setState(() {
                  for (var e in ColorMixModel.instance.rgbs) {
                    e.enabled = !val;
                  }
                });
              },
              visualDensity: VisualDensity(horizontal: -4),
            ),
            Container(
              width: cpntSize,
              height: cpntSize,
              margin: EdgeInsets.all(cpntSize / 8),
            ),
            const SizedBox(
              width: 4,
            ),
          ],
        ),
        for (int i = 0; i < ColorMixModel.instance.scales.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: TextField(
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(suffix: Text("%")),
                onSubmitted: (dynamic value) {
                  value = double.parse(value);
                  if (value <= 0 || value > 100) return;
                  setState(() {
                    ColorMixModel.instance.scales[i] = value / 100;
                  });
                },
                controller: TextEditingController(
                  text: (ColorMixModel.instance.scales[i] * 100)
                      .toStringAsFixed(2),
                ),
              ),
            ),
          ),
        Opacity(
          opacity: 0,
          child: IconButton(
            onPressed: null,
            visualDensity: VisualDensity(horizontal: -4),
            icon: Icon(Icons.add),
          ),
        )
      ],
    );
  }

  final double cpntSize = 50;

  Widget buildColorCpnts(BuildContext context) {
    double size = cpntSize;

    return Column(
      children: [
        for (int i = 0; i < ColorMixModel.instance.rgbs.length; i++)
          Row(
            children: [
              Checkbox(
                value: ColorMixModel.instance.rgbs[i].enabled,
                onChanged: (val) {
                  setState(() {
                    ColorMixModel.instance.rgbs[i].enabled = val == true;
                  });
                },
                visualDensity: VisualDensity(horizontal: -4),
              ),
              ColorCpnt(
                i.toString(),
                size: size,
              ),
              const SizedBox(
                width: 4,
              ),
              for (double scale in ColorMixModel.instance.scales)
                buildPercent(size, i, scale),
              IconButton(
                visualDensity: VisualDensity(horizontal: -4),
                onPressed: () async {
                  if (ColorMixModel.instance.rgbs.length <= 2) return;

                  if (true ==
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("?????????????????????"),
                          actions: [
                            TextButton(
                              child: Text("??????"),
                              onPressed: () => Navigator.pop(context, false),
                            ),
                            TextButton(
                              child: Text("??????"),
                              onPressed: () => Navigator.pop(context, true),
                            ),
                          ],
                        ),
                      )) {
                    ColorMixModel.instance.rgbs.removeAt(i);
                    setState(() {});
                  }
                },
                icon: Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        TextButton.icon(
            onPressed: () {
              if (ColorMixModel.instance.rgbs.length >= 999) return;
              setState(() {
                ColorMixModel.instance.rgbs.add(CpntModel(Colors.black));
              });
            },
            icon: Icon(Icons.add),
            label: Text("??????"))
      ],
    );
  }

  Widget buildMixedColor(BuildContext context) {
    return ColorCpnt(
      "B",
      size: 64,
      label: "B",
      enabled: false,
    );
  }

  void calcPercents(int algoIndex) async {
    showLoadingDialog(context);
    try {
      await ColorMixModel.instance.getPercents(algoIndex: algoIndex);
      setState(() {});
    } finally {
      Navigator.pop(context);
    }
  }

  Widget buildTargetColor(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8)),
      padding: EdgeInsets.symmetric(vertical: 8),
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildMixedColor(context),
              Column(
                children: [
                  Icon(Icons.arrow_right_alt, size: 32),
                  Text("??RGB: " +
                      ColorMixModel.instance.chromaticAberration().join(",")),
                ],
              ),
              ColorCpnt(
                "A",
                size: 64,
                label: "A",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () => calcPercents(1), child: Text("????????????")),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                  onPressed: () => calcPercents(0), child: Text("????????????")),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!ColorMixModel.initialized) return CircularProgressIndicator();
    return Scaffold(
      appBar: AppBar(
        title: Text("?????????"),
        actions: [
          TextButton(
              onPressed: () async {
                var value = await Clipboard.getData("text/plain");
                if (value == null) {
                  message("?????????????????????");
                  return;
                }
                if (await ColorMixModel.instance.loadJson(value.text)) {
                  message("????????????");
                  setState(() {});
                }
              },
              child: Text("??????")),
          TextButton(
              onPressed: () async {
                String data = await ColorMixModel.instance.saveJson();
                Clipboard.setData(ClipboardData(text: data));
                message("???????????????????????????");
              },
              child: Text("??????")),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            buildTargetColor(context),
            Align(
                alignment: Alignment.centerRight, child: buildScales(cpntSize)),
            Expanded(
              child: SingleChildScrollView(
                child: buildColorCpnts(context),
              ),
            )
          ],
        ),
      ),
    );
  }
}
