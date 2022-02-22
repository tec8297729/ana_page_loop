import 'package:flutter/material.dart';
import '../event_loop/ana_page_loop.dart' show anaPageLoop;
import '../observer/ana_controller_obs.dart';

class PageViewMixinData {
  PageController controller;

  /// 自定义每个tab页面名称，用与埋点记录，与pageController.page索引一一对应
  ///
  /// 例如：['首页','搜索']，tab索引0的对应首页
  List<String> tabsData;

  PageViewMixinData({
    required this.controller,
    required this.tabsData,
  });
}

/// 混合监听类，用于页面中有PageController事件埋点记录。
///
/// 使用方式：继承在组件页面中，并且实现initPageViewListener方法，传入具体参数，以及调用RouteAware类上的相关方法
mixin PageViewListenerMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  late PageViewMixinData _pageViewMixinData;
  double? _anaOldPage; // 上次位置
  double _anaCacheIndex = 0;
  Map<double, String> _anaPageNameData = Map();
  // bool _pushAnaFlag2147483648 = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((v) {
      _pageViewMixinData = initPageViewListener()!;
      _handleTabListener();
    });
  }

  /// 自动初始化PageViewListenerMixin所需要的参数
  PageViewMixinData? initPageViewListener() => null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    anaControllerObs.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    anaControllerObs.unsubscribe(this);
    super.dispose();
  }

  /// 监听tab
  void _handleTabListener() {
    PageController? pageCtr = _pageViewMixinData.controller;
    List<String> tabsData = _pageViewMixinData.tabsData;
    for (var i = 0; i < tabsData.length; i++) {
      _anaPageNameData[i.toDouble()] = tabsData[i];
    }
    pageCtr.addListener(() {
      _anaCacheIndex = pageCtr.page!;
      String? newPageName = _anaPageNameData[_anaCacheIndex];
      if (newPageName != null && _anaCacheIndex != _anaOldPage) {
        if (_anaOldPage != null) {
          var pageName = _anaPageNameData[_anaOldPage];
          if (pageName != null) anaPageLoop.endPageView(pageName); // 结束统计
        }

        // 开始统计
        anaPageLoop.beginPageView(newPageName);
        _anaOldPage = _anaCacheIndex;
      }
    });
  }

  @mustCallSuper
  @protected
  void didPopNext() {
    // next回退
    _popAnalyze(false);
    // _pushAnaFlag2147483648 = false;
  }

  @mustCallSuper
  @required
  void didPop() {
    _popAnalyze(true);
  }

  /// 回退统计
  _popAnalyze(bool isEnd) {
    _anaOldPage = _pageViewMixinData.controller.page;
    var pageName = _anaPageNameData[_anaOldPage];
    if (isEnd) {
      if (pageName != null) anaPageLoop.endPageView(pageName);
    } else {
      if (pageName != null) anaPageLoop.beginPageView(pageName);
    }
  }

  @mustCallSuper
  @required
  void didPush() {
    // 跳转当前页面,替换路由
    WidgetsBinding.instance?.addPostFrameCallback((v) {
      // if (_pushAnaFlag2147483648) return; // 禁止重复
      // _pushAnaFlag2147483648 = true;
      // ignore: unnecessary_null_comparison
      if (_pageViewMixinData != null) {
        anaPageLoop.beginPageView(
            _anaPageNameData[_pageViewMixinData.controller.page]!);
        if (_anaOldPage != null) {
          anaPageLoop.endPageView(_anaPageNameData[_anaOldPage]!); // 结束统计
        }
        _anaOldPage = _pageViewMixinData.controller.page;
      }
    });
  }

  @mustCallSuper
  @required
  void didPushNext() {
    // 跳转其它页面，单纯push
    anaPageLoop.endPageView(_anaPageNameData[_anaOldPage]!);
  }
}
