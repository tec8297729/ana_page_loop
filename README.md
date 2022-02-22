简单的全局路由埋点处理插件

建议用在不太复杂的埋点场景中使用。

## 安装插件

在flutter项目中的pubspec.yaml，添加以下依赖项：<br>

```
dependencies:
  ...
  ana_page_loop: ^x.x.x // 指定插件版本
```

## 使用方式

1、在MyApp入口处初始化anaPageLoop.init，并且添加监听对象anaAllObs。<br>

```dart
import 'package:ana_page_loop/ana_page_loop.dart' show anaPageLoop, anaAllObs;

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
      debug: false, // 是否开启调试，会输出路由栈相关信息
      // 自定义替换路由名称(可选参数)，用于自定义埋点统计名称
      routeName: {
        '/home': '热门新闻', // 将原始/home路由名称 替换成 热门新闻
        '/search': '搜索页面',
      },
    );
    return MaterialApp(
      navigatorObservers: [
        // 添加路由监听
        ...anaAllObs(),
      ],
    );
  }
}
```

常规页面监听埋点处理完成，如有tab切换页面独立统计的，需要单独配置继承类<br><br>

anaPageLoop.init参数介绍<br>

|    参数     |        类型         | default |                          说明                          |
| :---------: | :-----------------: | :-----: | :----------------------------------------------------: |
| beginPageFn |      Function       |         | 添加第三方埋点统计代码beginPageFn，与endPageFn配对使用 |
|  endPageFn  |      Function       |         |       添加第三方埋点统计代码endPageFn，结束统计        |
| routeRegExp |    List<String>     |         |                自定义过滤某些的路由统计                |
|    debug    |        bool         |  false  |           是否开启调试，会输出路由栈相关信息           |
|  routeName  | Map<String, String> |         |        自定义替换原始路由名称，用于埋点统计名称        |

### anaPageLoop相关方法介绍<br>

```dart
import 'package:ana_page_loop/ana_page_loop.dart' show anaPageLoop;

// 手动添加某页面埋点，传入当前页面名称（自定义）。只有特殊需求才需要手动添加
anaPageLoop.beginPageView('A页面'); // A页面 开始统计，和endPageView配对使用
anaPageLoop.endPageView('A页面'); // A页面 结束统计

anaPageLoop.pause(); // 临时暂停anaPageLoop监听流，可被唤醒
anaPageLoop.resume(); // 唤醒anaPageLoop流

anaPageLoop.close(); /// 完全关闭anaPageLoop监听流
```

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
