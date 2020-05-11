import 'package:flutter/material.dart';
import '../../components/RoutsAnimation/RoutsAnimation.dart';
import '../Home/Home.dart';
import '../components/BtnWidget.dart';

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
