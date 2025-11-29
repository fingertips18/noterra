import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noterra/constants/status.dart';

void toast({required String message, required Status status}) {
  Fluttertoast.showToast(
    msg: message,
    backgroundColor: status == Status.success ? Colors.greenAccent : Colors.redAccent,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
  );
}
