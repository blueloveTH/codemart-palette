import 'package:flutter/material.dart';
import 'package:palette/model.dart';
import 'package:palette/picker.dart';

class ColorCpnt extends StatefulWidget {
  final double size;
  final String label;
  final String dataKey;
  final bool enabled;

  const ColorCpnt(this.dataKey,
      {Key? key, required this.size, required this.label, this.enabled = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ColorCpntState();
}

class ColorCpntState extends State<ColorCpnt> {
  Color get color => ColorMixModel.instance.getColor(widget.dataKey);

  void pickColor() async {
    Color? newColor = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PickerDialog(
          initialColor: color,
        );
      },
    );

    if (newColor == null) return;

    setState(() {
      ColorMixModel.instance.setColor(widget.dataKey, newColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? pickColor : null,
      child: Container(
        width: widget.size,
        height: widget.size,
        margin: EdgeInsets.all(widget.size / 8),
        decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(8)),
        child: Center(
            child: Text(
          widget.label,
          style: TextStyle(
              color:
                  color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
        )),
      ),
    );
  }
}
