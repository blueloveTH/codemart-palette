import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:palette/config.dart';
import 'package:palette/message.dart';
import 'package:palette/model.dart';

class ColorDB extends StatefulWidget {
  final Color currentColor;
  ColorDB({required this.currentColor});

  @override
  ColorDBState createState() => ColorDBState();
}

class ColorDBState extends State<ColorDB> {
  Map<int, String> get colorDB => ColorMixModel.instance.colorDB;

  Color selectedColor = Color(ColorMixModel.instance.colorDB.keys.first);

  List<Color> get sortedColorDB {
    var lst = colorDB.keys.toList()
      ..sort((a, b) => colorDB[a]!.compareTo(colorDB[b]!));
    return lst.map((e) => Color(e)).toList();
  }

  Widget _itemBuilder(
      Color color, bool isCurrentColor, void Function() changeColor) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
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
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isCurrentColor ? 1 : 0,
                child: Icon(Icons.done,
                    color: useWhiteForeground(color)
                        ? Colors.white
                        : Colors.black),
              ),
            ),
          ),
        ),
        TextButton(
            onPressed: () async {
              TextEditingController controller = TextEditingController(
                  text: ColorMixModel.instance.getKeyByColor(color));
              String? key = await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: Text("请输入内部色号"),
                        content: TextField(
                          autofocus: true,
                          controller: controller,
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context,
                                  controller.text.trim().toUpperCase()),
                              child: Text("确定"))
                        ],
                      ));
              if (key != null) {
                ColorMixModel.instance.colorDB[color.value] = key;
                setState(() {});
              }
            },
            child: Text(ColorMixModel.instance.getKeyByColor(color))),
      ],
    );
  }

  Widget _layoutBuilder(
      BuildContext context, List<Color> colors, PickerItem child) {
    return GridView.count(
      crossAxisCount: 4,
      children: [for (Color color in colors) child(color)],
    );
  }

  void addColor(Color color) {
    if (colorDB.containsKey(color)) {
      message("颜色已经存在");
      return;
    }

    setState(() {
      colorDB[color.value] = noColorKey;
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
          availableColors: sortedColorDB,
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
