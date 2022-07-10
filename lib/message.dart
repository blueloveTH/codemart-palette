import 'package:flutter/material.dart';
import 'package:palette/config.dart';

void message(String text) {
  BuildContext context = globalKey.currentContext!;
  var messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(SnackBar(
    content: Text(text),
    behavior: SnackBarBehavior.floating,
    action: SnackBarAction(
      label: "忽略",
      onPressed: (() => messenger.hideCurrentSnackBar()),
      textColor: Theme.of(context).colorScheme.surface,
    ),
  ));
}
