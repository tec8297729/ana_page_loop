import 'package:flutter/material.dart';
import 'package:ana_page_loop/ana_page_loop.dart';
import '../components/BtnWidget.dart';
import 'HomeTabsPage.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with PageViewListenerMixin {
  int currentIndex = 0; // 接收bar当前点击索引
  late PageController pageController;
  @override
  void initState() {
    super.initState();
    initPageCtr();
    WidgetsBinding.instance.addPostFrameCallback((v) {});
  }

  @override
  PageViewMixinData initPageViewListener() {
    return PageViewMixinData(
      controller: pageController,
      tabsData: ['首页', '搜索', '分类', '会员中心'],
    );
  }

  void initPageCtr() {
    pageController = PageController();
  }

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
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: PageView(
        controller: pageController, // 控制器
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                BtnWidget('子页面Search', () {
                  Navigator.pushNamed(context, 'Search');
                }),
                BtnWidget('子页面MyTabsPage', () {
                  Navigator.pushNamed(context, 'MyTabsPage');
                }),
                BtnWidget('手动离开首页', () {
                  anaPageLoop.endPageView('首页');
                }),
                BtnWidget('手动开始A', () {
                  anaPageLoop.beginPageView('A页面');
                }),
                BtnWidget('手动结束A', () {
                  anaPageLoop.endPageView('A页面');
                }),
                BtnWidget('关闭流', () {
                  anaPageLoop.close();
                }),
              ],
            ),
          ),
          Container(
            color: Colors.amber,
            child: HomeTabsPage(pageController),
          ),
          Container(
            color: Colors.cyanAccent,
            child: Text('cyanAccent页面'),
          ),
          Container(
            color: Colors.lightGreenAccent,
            child: Text('lightGreenAccent页面'),
          ),
        ],
        // 监听当前滑动到的页数
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),

      // 底部栏
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // 只有设置fixed类型，底部bar才会显示所有的文字
          currentIndex: currentIndex, // 当前活动的bar索引
          // 点击事件
          onTap: (int idx) {
            setState(() {
              currentIndex = idx; // 存当前点击索引值
            });
            pageController.jumpToPage(idx); // 跳转到指定页
          },
          items: generateBottomBars(), // 底部菜单导航
        ),
      ),
    );
  }

  // 生成底部菜单导航
  List<BottomNavigationBarItem> generateBottomBars() {
    List<BottomNavigationBarItem> list = [];
    for (var idx = 0; idx < 4; idx++) {
      list.add(BottomNavigationBarItem(
        icon: Icon(
          Icons.account_circle, // 图标
          size: 28,
        ),
        label: '页面$idx',
      ));
    }
    return list;
  }
}
