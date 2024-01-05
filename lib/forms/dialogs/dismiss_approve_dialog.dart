import 'package:flutter/material.dart';

class DismissApproveDialog extends StatelessWidget {
  final String name;

  const DismissApproveDialog({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Are you sure you want to dismiss:"),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(name, style: Theme.of(context).textTheme.titleMedium,),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Cancel")),
                  ),
                  Expanded(
                    child: TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("Ok")),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
