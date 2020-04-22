import 'package:ana_page_loop_example/pages/components/BtnWidget.dart';
import 'package:flutter/material.dart';
import 'package:ana_page_loop/ana_page_loop.dart';

class MyTabsPage extends StatefulWidget {
  @override
  _MyTabsPageState createState() => _MyTabsPageState();
}

class _MyTabsPageState extends State<MyTabsPage>
    with
        AutomaticKeepAliveClientMixin,
        SingleTickerProviderStateMixin,
        TabViewListenerMixin {
  @override
  bool get wantKeepAlive => true;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  TabViewMixinData initPageViewListener() {
    return TabViewMixinData(
      tabsData: ['转转', '头条', '热点', '趣事'],
      controller: _tabController,
    );
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
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search页面'),
      ),
      body: Column(
        children: <Widget>[
          ...testTabWidget(),
          BtnWidget('跳转3级子页面', () {
            Navigator.pushNamed(context, 'AccountPage');
          }),
        ],
      ),
    );
  }

  List<Widget> testTabWidget() {
    return [
      Container(
        width: 300,
        height: 60,
        child: TabBar(
          controller: _tabController, // 动画状态定义
          // 选项卡显示的组件
          tabs: <Widget>[
            Icon(
              Icons.new_releases,
              color: Colors.black,
            ),
            Icon(
              Icons.picture_as_pdf,
              color: Colors.black,
            ),
            Tab(
              icon: Icon(
                Icons.accessible_forward,
                color: Colors.black,
              ),
              child: Container(child: Text('text')),
            )
          ],
          // tab标签页点击事件
          onTap: (int index) {},
        ),
      ),
      Container(
        width: 300,
        height: 100,
        child: TabBarView(
          controller: _tabController,
          // 里面定义不同tab显示的内容
          children: [
            Container(
              color: Colors.lightBlue,
            ),
            Container(
              color: Colors.greenAccent,
            ),
            Container(
              color: Colors.deepPurple,
            ),
          ],
        ),
      ),
    ];
  }
}
