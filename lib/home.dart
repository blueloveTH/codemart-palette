import 'package:flutter/material.dart';
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
        for (int i = 0; i < 5; i++)
          Row(
            children: [
              ColorCpnt(
                size: size,
                child: Text(
                  i.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              SizedBox(
                height: size,
                width: size * 1.4,
                child: TextFormField(
                  initialValue: "100.00",
                  decoration: const InputDecoration(
                    suffix: Text("%"),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget buildMixedColor(BuildContext context) {
    return ColorCpnt(
      size: 64,
      child: Text(
        "A",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("调色盘")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildColorCpnts(context),
              buildMixedColor(context),
            ]),
      ),
    );
  }
}
