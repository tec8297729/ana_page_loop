import 'package:ana_page_loop_example/pages/components/BtnWidget.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search页面'),
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: Text('Search'),
          ),
          BtnWidget('跳转3级子页面', () {
            Navigator.pushNamed(context, 'AccountPage');
          }),
        ],
      ),
    );
  }
}
