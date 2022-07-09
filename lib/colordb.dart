import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorDB extends StatelessWidget {
  final List<Color> allColors = [Colors.white];

  Widget _layoutBuilder(
      BuildContext context, List<Color> colors, PickerItem child) {
    return GridView.count(
      crossAxisCount: 5,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      children: [for (Color color in colors) child(color)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("颜色库")),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlockPicker(
          pickerColor: Colors.white,
          availableColors: allColors,
          onColorChanged: (c) {
            Navigator.pop(context, c);
          },
          useInShowDialog: false,
          layoutBuilder: _layoutBuilder,
        ),
      ),
    );
  }
}
