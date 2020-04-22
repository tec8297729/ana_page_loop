简单的全局路由埋点处理插件

建议用在不太复杂的埋点场景中使用。

## 使用方式

1、在MyApp入口处初始化anaPageLoop.init，并且添加监听对象anaAllObs。<br>

```dart
// ...省略
import 'package:ana_page_loop/ana_page_loop.dart' show anaPageLoop, anaAllObs;
// ...
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    anaPageLoop.init(
      beginPageFn: (name) {
        // 加入第三方统计代码(开始统计)
      },
      endPageFn: (name) {
        // 加入第三方统计代码(结束统计)
      },
      routeRegExp: ['/home', '/accountPage'], // 指定过滤的路由，当PageView或Tab组件要单独统计时，当前路由名称需要过滤掉。
    );
    return MaterialApp(
      // ...
      navigatorObservers: [
        // 添加路由监听
        ...anaAllObs(),
      ],
    );
  }
}
```
<br>
常规页面监听埋点处理完成，如有tab切换页面独立统计的，需要单独配置继承类<br><br>


## PageViewListenerMixin类介绍
<br>
监听带有PageController类的组件页面，并且自动记录埋点事件。

首先在anaPageLoop.init中（routeRegExp）配置过滤掉当前route路由名称，然后继承PageViewListenerMixin类，演示PageView组件页面具体如下：<br>

```dart
// 当前路由页面名称是 /home
class _HomeBarTabsState extends State<HomeBarTabs> with PageViewListenerMixin {
  PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }

  // 实现PageViewListenerMixin类上的方法
  @override
  PageViewMixinData initPageViewListener() {
    return PageViewMixinData(
      controller: pageController, // 传递PageController控制器
      tabsData: ['首页', '分类', '购物车', '我的中心'], // 自定义每个页面记录的名称
    );
  }

  // 调用如下几个生命周期
  @override
  void didPopNext() {
    super.didPopNext();
  }

  @override
  void didPop() {
    super.didPop();
  }

  @override
  void didPush() {
    super.didPush();
  }

  @override
  void didPushNext() {
    super.didPushNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController, // 控制器
        children: <Widget>[],
      ),
      // ...
    );
  }
}
```
<br>

## TabViewListenerMixin类介绍

监听带有TabController类的组件页面，并且自动记录埋点事件。

首先在anaPageLoop.init中（routeRegExp）配置过滤掉当前route路由名称，然后继承TabViewListenerMixin类<br>

演示TabBarView组件页面具体如下：<br>

```dart
// 当前路由页面名称是 /accountPage
class _AccountPageState extends State<HomeBarTabs> with SingleTickerProviderStateMixin, TabViewListenerMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // 实现TabViewListenerMixin类上的方法
  @override
  TabViewMixinData initPageViewListener() {
    return TabViewMixinData(
      controller: _tabController, // 传递tab控制器
      tabsData: ['热门', '头条', '热点', '趣事'], // 用于记录每个tab页面的名称
    );
  }

  // 调用如下几个生命周期
  @override
  void didPopNext() {
    super.didPopNext();
  }

  @override
  void didPop() {
    super.didPop();
  }

  @override
  void didPush() {
    super.didPush();
  }

  @override
  void didPushNext() {
    super.didPushNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController, // 控制器
        children: <Widget>[],
      ),
      // ...
    );
  }
}
```

