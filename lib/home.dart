import 'package:flutter/material.dart';
import 'package:palette/config.dart';
import 'package:palette/cpnt.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Color colorA = Colors.white;

  Widget buildColorCpnts(BuildContext context) {
    double size = 48;

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
              SizedBox(
                height: size,
                width: size * 1.5,
                child: TextFormField(
                  initialValue: "100.00",
                  decoration: const InputDecoration(
                    suffix: Text("%"),
                  ),
                  autofocus: false,
                  keyboardType: TextInputType.number,
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
          "A",
          size: 64,
          label: "A",
        ),
        ElevatedButton(onPressed: () {}, child: Text("计算配比")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("调色盘")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildColorCpnts(context),
                  buildMixedColor(context),
                ]),
            /*Padding(
              padding: const EdgeInsets.all(8.0),
              child: PickerValueTable(initialColor: ColorMixModel.instance.A),
            ),*/
          ],
        ),
      ),
    );
  }
}
