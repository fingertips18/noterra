import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> Confirmation({
  required String title,
  content,
  required BuildContext context,
  required Function action,
  bool isKeyInvolved = false,
  int key = 0,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      if (Platform.isIOS) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              child: const Text("Yes"),
              onPressed: () {
                if (isKeyInvolved) {
                  action(key: key);
                } else {
                  action();
                }
              },
            ),
            CupertinoDialogAction(
              child: const Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      } else {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            ElevatedButton(
              child: const Text("Yes"),
              onPressed: () {
                if (isKeyInvolved) {
                  action(key: key);
                } else {
                  action();
                }
              },
            ),
            ElevatedButton(
              child: const Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    },
  );
}
