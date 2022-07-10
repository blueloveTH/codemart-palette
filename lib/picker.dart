import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_color_models/flutter_color_models.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:palette/colordb.dart';
import 'package:provider/provider.dart';

class MultiCpntField extends StatelessWidget {
  final String label;
  final List<Object> values;
  final List<TextEditingController> controllers = [];
  final bool fixedWidth;
  final int maxLength;

  final void Function(MultiCpntField field) onEditComplete;
  final Color Function(MultiCpntField field) toColor;

  int get fieldLength => values.length;

  String getText(int i) => controllers[i].text;
  int getInt(int i) => int.parse(getText(i));
  List<int> getValueList() =>
      controllers.map<int>((e) => int.parse(e.text)).toList();

  MultiCpntField(this.label, this.values,
      {this.fixedWidth = false,
      required this.toColor,
      required this.onEditComplete,
      this.maxLength = 3}) {
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
                maxLength: maxLength,
                enableIMEPersonalizedLearning: false,
                keyboardType: TextInputType.number,
                autocorrect: false,
                style: TextStyle(fontSize: 14),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                onEditingComplete: () => onEditComplete(this),
              ),
            ),
        ],
      ),
    );
  }
}

class PickerValueTable extends StatelessWidget {
  final Color initialColor;
  final void Function(Color c)? onColorEdit;

  PickerValueTable({required this.initialColor, this.onColorEdit});

  void refreshColor(MultiCpntField field) {
    try {
      Color c = field.toColor(field);
      onColorEdit?.call(c);
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    RgbColor rgb = initialColor.toRgbColor();
    HSVColor hsv = HSVColor.fromColor(rgb.toColor());
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MultiCpntField(
          "RGB",
          rgb.toList(),
          toColor: (field) => RgbColor.fromList(field.getValueList()),
          onEditComplete: refreshColor,
        ),
        MultiCpntField(
          "CMYK",
          rgb.toCmykColor().toList(),
          toColor: (field) => CmykColor.fromList(field.getValueList()),
          onEditComplete: refreshColor,
        ),
        MultiCpntField(
          "HSV",
          [hsv.hue, hsv.saturation * 100, hsv.value * 100],
          toColor: (field) => HSVColor.fromAHSV(1.0, field.getInt(0) * 1.0,
                  field.getInt(1) * 0.01, field.getInt(2) * 0.01)
              .toColor(),
          onEditComplete: refreshColor,
        ),
        MultiCpntField(
          "HEX",
          [rgb.hex],
          fixedWidth: true,
          maxLength: 7,
          toColor: (field) => RgbColor.fromHex(field.getText(0)),
          onEditComplete: refreshColor,
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
    XFile? file = await ImagePicker().pickImage(source: src, maxHeight: 600, maxWidth: 300);
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
                      onColorEdit: (c) =>
                          textController.text = c.toRgbColor().hex,
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
                    IconButton(
                        onPressed: () async {
                          Color? color = await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => ColorDB(currentColor: currentColor,)));
                          if (color != null) {
                            textController.text = color.toRgbColor().hex;
                          }
                        },
                        icon: Icon(Icons.palette_outlined)),
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
