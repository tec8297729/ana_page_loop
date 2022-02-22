import 'package:flutter/material.dart';

class BtnWidget extends StatelessWidget {
  BtnWidget(this.text, this.fn);
  final String text;
  final VoidCallback fn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text(text),
        onPressed: fn,
      ),
    );
  }
}
