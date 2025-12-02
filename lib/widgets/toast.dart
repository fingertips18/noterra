import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noterra/constants/status.dart';

void toast({required String message, required Status status}) {
  MaterialAccentColor backgroundColor;
  switch (status) {
    case Status.info:
      backgroundColor = Colors.blueAccent;
      break;
    case Status.success:
      backgroundColor = Colors.greenAccent;
      break;
    case Status.error:
      backgroundColor = Colors.redAccent;
      break;
  }

  Fluttertoast.showToast(msg: message, backgroundColor: backgroundColor, toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM);
}
