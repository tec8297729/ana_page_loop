import 'package:flutter/material.dart';
import './ana_controller_bbs.dart' show anaControllerObs;
import './analytics_obs.dart' show AnalyticsObs;

/// 所有navigatorObservers监听对象
List<NavigatorObserver> anaAllObs() {
  return [anaControllerObs, AnalyticsObs()];
}
