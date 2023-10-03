import 'package:flutter/material.dart';

class FormTextInputCard extends StatelessWidget {
  const FormTextInputCard({
    super.key,
    this.onSaved,
    this.validator,
    required this.title,
    this.controller,
    this.initValue,
  });

  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final String title;
  final TextEditingController? controller;
  final String? initValue;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(title),
            ),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onSaved: onSaved,
              controller: controller,
              validator: validator,
              initialValue: initValue,
            ),
          ],
        ),
      ),
    );
  }
}
