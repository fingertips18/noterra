import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart'
    show
        BoxConstraints,
        BuildContext,
        Column,
        ConstrainedBox,
        CupertinoAlertDialog,
        CupertinoButton,
        CupertinoDialogAction,
        ListView,
        MainAxisSize,
        Navigator,
        SingleChildScrollView,
        SizedBox,
        Text,
        TextOverflow,
        showCupertinoDialog;
import 'package:flutter/material.dart'
    show
        AlertDialog,
        BoxConstraints,
        BuildContext,
        Column,
        ConstrainedBox,
        ListTile,
        ListView,
        MainAxisSize,
        Navigator,
        SingleChildScrollView,
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
            content: const Text('Please add a template first before generating reports'),
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  ...templates.map((template) => CupertinoButton(child: Text(template.title), onPressed: () => Navigator.of(context).pop(template))),
                  CupertinoButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
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
              final truncatedBody = template.body.length > 60 ? "${template.body.substring(0, 60)}..." : template.body;

              return ListTile(
                title: Text(template.title),
                subtitle: Text(truncatedBody, maxLines: 2, overflow: TextOverflow.ellipsis),
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
