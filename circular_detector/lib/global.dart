import 'package:flutter/material.dart';

String server_address = "http://192.168.154.58:5000";
ValueNotifier login = ValueNotifier(0);

buildShowDialog(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      });
}
