import 'package:flutter/material.dart';

import 'pages/AccountPage/AccountPage.dart';
import 'pages/Home/Home.dart';
import 'pages/MyTabsPage/MyTabsPage.dart';
import 'pages/Search/Search.dart';

final Map<String, WidgetBuilder> routesData = {
  '/': (BuildContext context, {params}) => Home(),
  'Search': (BuildContext context, {params}) => Search(),
  'AccountPage': (BuildContext context, {params}) => AccountPage(),
  'MyTabsPage': (BuildContext context, {params}) => MyTabsPage(),
};
