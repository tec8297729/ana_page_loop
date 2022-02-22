import 'package:flutter/material.dart';
import 'AnaControllerObs.dart' show anaControllerObs;
import 'AnalyticsObs.dart' show AnalyticsObs;

/// 所有navigatorObservers监听对象
List<NavigatorObserver> anaAllObs() {
  return [anaControllerObs, AnalyticsObs()];
}
