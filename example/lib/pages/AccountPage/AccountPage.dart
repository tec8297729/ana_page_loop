import 'package:ana_page_loop_example/components/RoutsAnimation/RoutsAnimation.dart';
import 'package:ana_page_loop_example/pages/components/BtnWidget.dart';
import 'package:ana_page_loop_example/pages/home/home.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AccountPage页面'),
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: Text('AccountPage'),
          ),
          BtnWidget('popUntil跳转', () {
            Navigator.pushNamed(context, '/');
          }),
          BtnWidget('pushAndRemoveUntil跳转', () {
            Navigator.pushAndRemoveUntil(
              context,
              RoutsAnimation(
                child: Home(),
                settings: RouteSettings(name: '/'),
              ),
              (Route<dynamic> route) => false,
            );
          }),
        ],
      ),
    );
  }
}
