import 'package:flutter/material.dart';
import '../observer/AnaControllerObs.dart';
import '../eventLoop/AnaPageLoop.dart' show anaPageLoop;
import '../utils/anaLog.dart';

class TabViewMixinData {
  /// tab控制器
  TabController controller;

  /// 自定义每个tab页面名称，用与埋点记录
  List<String> tabsData;

  TabViewMixinData({
    @required this.controller,
    @required this.tabsData,
  });
}

/// 混合监听类，用于页面中有TabController事件埋点记录。
///
/// 使用方式：继承在组件页面中，并且实现initPageViewListener方法，传入具体参数，以及调用RouteAware类上的相关方法，用法和PageViewListenerMixin类相同
mixin TabViewListenerMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  TabViewMixinData _tabViewMixinData;
  int _oldTabIdx; // 上次位置
  int _cacheIndex = 0; // tab索引缓存
  Map<int, String> _tabNameData = Map();
  bool _initAnalyzeFlag = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((v) {
      _tabViewMixinData = initPageViewListener();
      assert(_tabViewMixinData != null);
      _handleTabListener();
    });
  }

  /// 初始化tabViewMixin所需要的参数
  TabViewMixinData initPageViewListener() => null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    anaControllerObs.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    anaControllerObs.unsubscribe(this);
    super.dispose();
  }

  /// 监听tab
  _handleTabListener() {
    List<String> tabsData = _tabViewMixinData.tabsData;
    TabController tabCtr = _tabViewMixinData.controller;
    for (var i = 0; i < tabsData.length; i++) {
      _tabNameData[i] = tabsData[i];
    }

    tabCtr.addListener(() {
      _cacheIndex = tabCtr.index;
      String newPageName = _tabNameData[_cacheIndex];
      if (newPageName != null && _cacheIndex != _oldTabIdx) {
        AnaLog.p(_tabNameData[tabCtr.index]);
        if (_oldTabIdx != null) {
          // 结束统计
          anaPageLoop.endPageView(_tabNameData[_oldTabIdx]);
        }

        // 开始统计
        anaPageLoop.beginPageView(newPageName);
        _oldTabIdx = _cacheIndex;
      }
    });
  }

  @mustCallSuper
  @protected
  void didPopNext() {
    // next回退
    AnaLog.p(
        'tabViewMixin.didPopNext>>>${_tabViewMixinData.controller?.index}');
    _oldTabIdx = _tabViewMixinData.controller?.index;
    String pageName = _tabNameData[_oldTabIdx];
    anaPageLoop.beginPageView(pageName);
  }

  @mustCallSuper
  @required
  void didPop() {
    AnaLog.p('tabViewMixin.didPop》》》${_tabViewMixinData.controller?.index}');
    _oldTabIdx = _tabViewMixinData.controller?.index;
    String pageName = _tabNameData[_oldTabIdx];
    anaPageLoop.endPageView(pageName);
  }

  @mustCallSuper
  @required
  void didPush() {
    // 跳转当前页面,替换路由
    AnaLog.p('tabViewMixin.didPush');
    WidgetsBinding.instance.addPostFrameCallback((v) {
      if (_initAnalyzeFlag) return;
      _initAnalyzeFlag = true;
      AnaLog.p(
          'tabViewMixin._pushAnalyze  ${_tabViewMixinData.controller?.index}');
      anaPageLoop
          .beginPageView(_tabNameData[_tabViewMixinData.controller?.index]);
      if (_oldTabIdx != null) {
        // 结束统计
        anaPageLoop.endPageView(_tabNameData[_oldTabIdx]);
      }
      _oldTabIdx = _tabViewMixinData.controller?.index;
    });
  }

  @mustCallSuper
  @required
  void didPushNext() {
    // 跳转其它页面，单纯push
    AnaLog.p('tabViewMixin.didPushNext');
    // 结束统计
    anaPageLoop.endPageView(_tabNameData[_oldTabIdx]);
    _initAnalyzeFlag = false;
  }
}
