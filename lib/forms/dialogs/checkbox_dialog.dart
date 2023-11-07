import 'package:flutter/material.dart';

class CheckBoxDialog extends StatelessWidget {
  const CheckBoxDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
            "Clear all checked ingredients?"),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false);
                  },
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 5,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true);
                  },
                  child: const Text("Ok"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}