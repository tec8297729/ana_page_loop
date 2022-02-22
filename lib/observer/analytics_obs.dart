import 'package:flutter/material.dart';
import '../eventLoop/AnaPageLoop.dart' show anaPageLoop;

/// 监听路由
class AnalyticsObs extends NavigatorObserver {
  analytics(Route route, Route previousRoute) {
    String routeName = route?.settings?.name ?? 'null';
    String lastRouteName = previousRoute?.settings?.name ?? 'null';
    anaPageLoop.endPageView(lastRouteName);
    anaPageLoop.beginPageView(routeName);
  }

  // push跳转路由时触发
  @override
  void didPush(Route route, Route previousRoute) {
    super.didPush(route, previousRoute);
    String routeName = route?.settings?.name ?? 'null';
    if (routeName != 'null') {
      analytics(route, previousRoute);
    }
  }

  // pop回退路由时触发
  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    String routeName = route?.settings?.name ?? 'null';
    // popUntil
    if (routeName != 'null') {
      analytics(previousRoute, route);
    }
  }

  // remove移除路由时触发
  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didRemove(route, previousRoute);
    // print('移除路由>>>>${route.settings.name ?? 'null'}');
    // analytics(previousRoute, route);
  }

  /// 路由被替换时触发
  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    super.didReplace();
    String routeName = newRoute?.settings?.name ?? 'null';
    if (routeName != 'null') {
      analytics(newRoute, oldRoute);
    }
  }
}
