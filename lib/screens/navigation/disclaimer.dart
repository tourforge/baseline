import 'package:flutter/material.dart';

Future<void> showDisclaimer(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Disclaimer(),
  );
}

class Disclaimer extends StatelessWidget {
  const Disclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Driving Tour'),
      content: SingleChildScrollView(
        child: ListBody(
          children: const <Widget>[
            Text(
                'Remember to obey the law and pay attention to your surroundings while driving.'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Exit tour'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('I understand'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
