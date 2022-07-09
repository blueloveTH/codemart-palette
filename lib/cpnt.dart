import 'package:flutter/material.dart';

class ColorCpnt extends StatefulWidget {
  final double size;
  final Widget? child;

  const ColorCpnt({Key? key, required this.size, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ColorCpntState();
}

class ColorCpntState extends State<ColorCpnt> {
  Color color = Colors.black;

  void pickColor() async {
    Color? newColor = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CpntPicker(
                  initialColor: color,
                )));
    if (newColor == null) return;

    setState(() {
      color = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pickColor,
      child: Container(
        width: widget.size,
        height: widget.size,
        margin: EdgeInsets.all(widget.size / 8),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Center(child: widget.child),
      ),
    );
  }
}

class CpntPicker extends StatefulWidget {
  final Color initialColor;

  CpntPicker({required this.initialColor});

  @override
  State<StatefulWidget> createState() => CpntPickerState();
}

class CpntPickerState extends State<CpntPicker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("取色页面")),
      body: Column(children: []),
    );
  }
}
