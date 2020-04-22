import 'package:flutter/material.dart';

class BtnWidget extends StatelessWidget {
  BtnWidget(this.text, this.fn);
  final String text;
  final Function fn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        child: Text(text),
        onPressed: fn,
      ),
    );
  }
}
