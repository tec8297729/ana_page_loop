import 'package:flutter/material.dart';
import '../observer/AnaControllerObs.dart';
import '../eventLoop/AnaPageLoop.dart' show anaPageLoop;
import '../utils/anaLog.dart';

class PageViewMixinData {
  PageController controller;

  /// 自定义每个tab页面名称，用与埋点记录，与pageController.page索引一一对应
  ///
  /// 例如：['首页','搜索']，tab索引0的对应首页
  List<String> tabsData;

  PageViewMixinData({
    @required this.controller,
    @required this.tabsData,
  });
}

/// 混合监听类，用于页面中有PageController事件埋点记录。
///
/// 使用方式：继承在组件页面中，并且实现initPageViewListener方法，传入具体参数，以及调用RouteAware类上的相关方法
mixin PageViewListenerMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  PageViewMixinData _pageViewMixinData;
  double oldPage; // 上次位置
  double _cacheIndex = 0;
  Map<double, String> _pageNameData = Map();
  bool _initAnalyzeFlag = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((v) {
      _pageViewMixinData = initPageViewListener();
      assert(_pageViewMixinData != null);
      _handleTabListener();
    });
  }

  /// 初始化PageViewListenerMixin所需要的参数
  PageViewMixinData initPageViewListener() => null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    anaControllerObs.subscribe(this, ModalRoute.of(context));
    WidgetsBinding.instance.addPostFrameCallback((v) {
      AnaLog.p(
          'PageViewListenerMixin内部${_pageViewMixinData?.controller?.page}');
    });
  }

  @override
  void dispose() {
    AnaLog.p('子监听中dispose');
    anaControllerObs.unsubscribe(this);
    super.dispose();
  }

  /// 监听tab
  _handleTabListener() {
    List<String> tabsData = _pageViewMixinData.tabsData;
    PageController pageCtr = _pageViewMixinData.controller;
    for (var i = 0; i < tabsData.length; i++) {
      _pageNameData[i.toDouble()] = tabsData[i];
    }
    pageCtr.addListener(() {
      _cacheIndex = pageCtr.page;
      String newPageName = _pageNameData[_cacheIndex];
      if (newPageName != null && _cacheIndex != oldPage) {
        AnaLog.p(_pageNameData[pageCtr.page]);
        if (oldPage != null) {
          // 结束统计
          anaPageLoop.endPageView(_pageNameData[oldPage]);
        }

        // 开始统计
        anaPageLoop.beginPageView(newPageName);
        oldPage = _cacheIndex;
      }
    });
  }

  @mustCallSuper
  @protected
  void didPopNext() {
    // next回退
    AnaLog.p('didPopNext>>>${_pageViewMixinData.controller.page}');
    _popAnalyze(false);
  }

  @mustCallSuper
  @required
  void didPop() {
    AnaLog.p('didPop》》》${_pageViewMixinData.controller.page}');
    _popAnalyze(true);
    // ana_page_loop
  }

  /// 回退统计
  _popAnalyze(bool isEnd) {
    oldPage = _pageViewMixinData.controller.page;
    String pageName = _pageNameData[oldPage];
    if (isEnd) {
      anaPageLoop.endPageView(pageName);
    } else {
      anaPageLoop.beginPageView(pageName);
    }
  }

  @mustCallSuper
  @required
  void didPush() {
    // 跳转当前页面,替换路由
    AnaLog.p('didPush生命周期');
    _pushAnalyze();
  }

  @mustCallSuper
  @required
  void didPushNext() {
    // 跳转其它页面，单纯push
    AnaLog.p('didPushNext');
    // 结束统计
    anaPageLoop.endPageView(_pageNameData[oldPage]);
    _initAnalyzeFlag = false;
  }

  /// 跳转页面统计
  _pushAnalyze() {
    WidgetsBinding.instance.addPostFrameCallback((v) {
      if (_initAnalyzeFlag) return;
      _initAnalyzeFlag = true;
      AnaLog.p('_pushAnalyze  ${_pageViewMixinData.controller.page}');
      anaPageLoop
          .beginPageView(_pageNameData[_pageViewMixinData.controller.page]);
      if (oldPage != null) {
        // 结束统计
        anaPageLoop.endPageView(_pageNameData[oldPage]);
      }
      oldPage = _pageViewMixinData.controller.page;
    });
  }
}
