import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart' show CupertinoAlertDialog, CupertinoButton, CupertinoDialogAction, showCupertinoDialog;
import 'package:flutter/material.dart'
    show
        AlertDialog,
        BoxConstraints,
        BuildContext,
        Column,
        ConstrainedBox,
        Expanded,
        ListTile,
        ListView,
        MainAxisSize,
        Navigator,
        SizedBox,
        Text,
        TextButton,
        TextOverflow,
        showDialog;
import '/model/template.dart' show Template;

Future<Template?> showTemplateSelector(BuildContext context, {required List<Template> templates}) async {
  // Handle empty templates case
  if (templates.isEmpty) {
    if (Platform.isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('No Templates'),
            content: const Text('Please create a template first before generating reports'),
            actions: [CupertinoDialogAction(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
          );
        },
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('No Templates'),
            content: const Text('Please create a template first before generating reports'),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
          );
        },
      );
    }

    return null;
  }

  if (Platform.isIOS) {
    return await showCupertinoDialog<Template?>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Select Template'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: templates.length,
                    itemBuilder: (context, index) {
                      return CupertinoButton(child: Text(templates[index].title), onPressed: () => Navigator.of(context).pop(templates[index]));
                    },
                  ),
                ),
                CupertinoButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
          ),
        );
      },
    );
  }

  return await showDialog<Template?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Select Template'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];

              return ListTile(
                title: Text(template.title),
                subtitle: Text(template.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () => Navigator.of(context).pop(template),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))],
      );
    },
  );
}
