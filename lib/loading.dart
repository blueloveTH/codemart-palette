import 'package:flutter/material.dart';

void showLoadingDialog(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
            onWillPop: () => Future.value(false),
            child: AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 24,
                  ),
                  Text("正在计算"),
                ],
              ),
            ),
          ));
}
