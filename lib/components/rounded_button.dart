import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String btnName;
  final Color btnColor;
  final Function onBtnPress;
  RoundedButton(
      {required this.btnName,
      required this.btnColor,
      required this.onBtnPress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: btnColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: () {
            onBtnPress();
          },
          minWidth: 200.0,
          height: 42.0,
          child: Text(btnName),
        ),
      ),
    );
  }
}
