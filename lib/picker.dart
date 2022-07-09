import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_color_models/flutter_color_models.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MultiCpntField extends StatelessWidget {
  final String label;
  final List<Object> values;
  final List<TextEditingController> controllers = [];
  final bool fixedWidth;

  int get fieldLength => values.length;

  MultiCpntField(this.label, this.values, {this.fixedWidth = false}) {
    for (int i = 0; i < fieldLength; i++) {
      String text = values[i].toString();
      if (values[i] is num) text = (values[i] as num).round().toString();
      controllers.add(TextEditingController(text: text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(),
            width: 48,
            child: Text(label),
          ),
          for (int i = 0; i < fieldLength; i++)
            Container(
              width: 48 * (fixedWidth ? 3 : 1),
              padding: EdgeInsets.only(right: 2),
              child: CupertinoTextField(
                controller: controllers[i],
                maxLength: 3,
                enableIMEPersonalizedLearning: false,
                keyboardType: TextInputType.number,
                autocorrect: false,
                style: TextStyle(fontSize: 14),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                //decoration: BoxDecoration(border: Border.all()),
              ),
            ),
        ],
      ),
    );
  }
}

class PickerValueTable extends StatelessWidget {
  final Color initialColor;

  PickerValueTable({required this.initialColor});

  @override
  Widget build(BuildContext context) {
    RgbColor rgb = initialColor.toRgbColor();
    HSVColor hsv = HSVColor.fromColor(rgb.toColor());
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MultiCpntField("RGB", rgb.toList()),
        MultiCpntField("CMYK", rgb.toCmykColor().toList()),
        MultiCpntField("HSV", [hsv.hue, hsv.saturation * 100, hsv.value * 100]),
        MultiCpntField(
          "HEX",
          [rgb.hex],
          fixedWidth: true,
        ),
      ],
    );
  }
}

class PickerDialog extends StatefulWidget {
  final Color initialColor;

  PickerDialog({required this.initialColor});

  @override
  State<StatefulWidget> createState() => PickerDialogState();
}

class PickerDialogState extends State<PickerDialog> {
  final textController = TextEditingController();

  late Color currentColor = widget.initialColor;

  Future<Color?> pickColorFromImage(
      BuildContext context, ImageSource src) async {
    XFile? file = await ImagePicker().pickImage(source: src);
    if (file == null) return null;
    var image = img.decodeImage(await file.readAsBytes());
    if (image == null) return null;
    int abgr = image.getPixel(image.width ~/ 2, image.height ~/ 2);

    // #AABBGGRR
    // #AA000000
    // #00RR0000
    // #0000GG00
    // #000000BB
    int argb = 0xff000000 |
        ((abgr << 16) & 0x00ff0000) |
        ((abgr) & 0x0000ff00) |
        ((abgr >> 16) & 0x000000ff);

    return Color(argb);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(0),
      content: Column(
        children: [
          ColorPicker(
            pickerColor: widget.initialColor,
            onColorChanged: (c) {
              currentColor = c;
            },
            colorPickerWidth: 300,
            pickerAreaHeightPercent: 0.6,
            enableAlpha: false, // hexInputController will respect it too.
            displayThumbColor: true,
            paletteType: PaletteType.hsvWithHue,
            labelTypes: const [],
            pickerAreaBorderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
            hexInputController: textController, // <- here
            portraitOnly: true,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChangeNotifierProvider.value(
                  value: textController,
                  child: Consumer<TextEditingController>(
                    builder: (context, value, child) => PickerValueTable(
                      initialColor: currentColor,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () async {
                          var color = await pickColorFromImage(
                              context, ImageSource.gallery);
                          if (color != null) {
                            textController.text = color.toRgbColor().hex;
                          }
                        },
                        icon: Icon(
                          Icons.image_outlined,
                        )),
                    IconButton(
                        onPressed: () async {
                          var color = await pickColorFromImage(
                              context, ImageSource.camera);
                          if (color != null) {
                            textController.text = color.toRgbColor().hex;
                          }
                        },
                        icon: Icon(Icons.camera_alt_outlined)),
                    Expanded(
                        child: SizedBox(
                      width: 1,
                    )),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, currentColor);
                        },
                        child: Text("确定")),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
