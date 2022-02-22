import 'package:flutter/material.dart';
import '../observer/AnaControllerObs.dart';
import '../eventLoop/AnaPageLoop.dart' show anaPageLoop;

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
  int _anaOldTabIdx; // 上次位置
  int _anaCacheIndex = 0; // tab索引缓存
  Map<int, String> _anaTabNameData = Map();

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
      _anaTabNameData[i] = tabsData[i];
    }

    tabCtr.addListener(() {
      _anaCacheIndex = tabCtr.index;
      String newPageName = _anaTabNameData[_anaCacheIndex];
      if (newPageName != null && _anaCacheIndex != _anaOldTabIdx) {
        if (_anaOldTabIdx != null) {
          anaPageLoop.endPageView(_anaTabNameData[_anaOldTabIdx]); // 结束统计
        }

        // 开始统计
        anaPageLoop.beginPageView(newPageName);
        _anaOldTabIdx = _anaCacheIndex;
      }
    });
  }

  @mustCallSuper
  @protected
  void didPopNext() {
    // next回退
    _anaOldTabIdx = _tabViewMixinData.controller?.index;
    String pageName = _anaTabNameData[_anaOldTabIdx];
    anaPageLoop.beginPageView(pageName);
  }

  @mustCallSuper
  @required
  void didPop() {
    _anaOldTabIdx = _tabViewMixinData.controller?.index;
    String pageName = _anaTabNameData[_anaOldTabIdx];
    anaPageLoop.endPageView(pageName);
  }

  @mustCallSuper
  @required
  void didPush() {
    // 跳转当前页面,替换路由
    WidgetsBinding.instance.addPostFrameCallback((v) {
      if (_tabViewMixinData != null) {
        anaPageLoop.beginPageView(
            _anaTabNameData[_tabViewMixinData.controller?.index]);
        if (_anaOldTabIdx != null) {
          anaPageLoop.endPageView(_anaTabNameData[_anaOldTabIdx]); // 结束统计
        }
        _anaOldTabIdx = _tabViewMixinData.controller?.index;
      }
    });
  }

  @mustCallSuper
  @required
  void didPushNext() {
    // 跳转其它页面，单纯push
    anaPageLoop.endPageView(_anaTabNameData[_anaOldTabIdx]);
  }
}
