import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:palette/message.dart';
import 'package:palette/model.dart';

class ColorDB extends StatefulWidget {
  final Color currentColor;
  ColorDB({required this.currentColor});

  @override
  ColorDBState createState() => ColorDBState();
}

class ColorDBState extends State<ColorDB> {
  List<Color> get colorDB => ColorMixModel.instance.colorDB;

  Color selectedColor = ColorMixModel.instance.colorDB[0];

  Widget _itemBuilder(
      Color color, bool isCurrentColor, void Function() changeColor) {
    return Container(
      margin: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.6),
              offset: const Offset(1, 2),
              blurRadius: 2)
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: changeColor,
          borderRadius: BorderRadius.circular(50),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 210),
            opacity: isCurrentColor ? 1 : 0,
            child: Icon(Icons.done,
                color: useWhiteForeground(color) ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _layoutBuilder(
      BuildContext context, List<Color> colors, PickerItem child) {
    return GridView.count(
      crossAxisCount: 5,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      children: [for (Color color in colors) child(color)],
    );
  }

  void addColor(Color color) {
    if (colorDB.contains(color)) {
      message("颜色已经存在");
      return;
    }

    setState(() {
      colorDB.add(color);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("颜色库"),
        actions: [
          TextButton(
              onPressed: () {
                if (ColorMixModel.instance.colorDB.length <= 1) {
                  message("无法删除，至少需保留一种颜色");
                  return;
                }
                setState(() {
                  colorDB.remove(selectedColor);
                });
              },
              child: Text("删除")),
          TextButton(
              onPressed: () => addColor(widget.currentColor),
              child: Text("保存")),
          TextButton(
              onPressed: () => Navigator.pop(context, selectedColor),
              child: Text("选取")),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlockPicker(
          pickerColor: selectedColor,
          availableColors: colorDB,
          onColorChanged: (c) {
            setState(() {
              selectedColor = c;
            });
          },
          useInShowDialog: false,
          layoutBuilder: _layoutBuilder,
          itemBuilder: _itemBuilder,
        ),
      ),
    );
  }
}
