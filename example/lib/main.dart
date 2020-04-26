import 'package:ana_page_loop_example/routes.dart';
import 'package:flutter/material.dart';
import 'package:ana_page_loop/ana_page_loop.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    anaPageLoop.init(
      beginPageFn: (name) {
        print('记录开始》》》$name');
      },
      endPageFn: (name) {
        print('记录结束》》》$name');
      },
      routeRegExp: ['/', 'MyTabsPage'], // 过滤路由
      debug: true,
      // 自定义替换路由名称， key原始路由名称: value新路由名称
      routeName: {
        '首页': '美改页',
        'Search': '二级页面S',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: routesData,
      navigatorObservers: []..addAll(anaAllObs()),
    );
  }
}
