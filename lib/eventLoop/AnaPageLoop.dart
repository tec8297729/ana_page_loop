import 'dart:async';
import 'package:flutter/cupertino.dart';

enum _IRouterState {
  /// 页面进入
  enter,

  /// 页面离开
  exit,
}

class _IStreamData {
  /// 路由名称
  String name;

  /// 路由状态
  _IRouterState state;

  /// 时间
  DateTime time;

  _IStreamData({this.name, this.state, this.time});
}

AnaPageLoop anaPageLoop = AnaPageLoop();

typedef void UserPageCallbackFn(String routerName);

class AnaPageLoop {
  bool _initFlag = false;
  _IStreamData _lastRoute = _IStreamData(); // 上一次路由
  List<_IStreamData> _routeStack = []; // 路由栈
  StreamController<_IStreamData> _streamCtr = StreamController<_IStreamData>();
  Stream streamPeriodic;
  UserPageCallbackFn _userBeginPageFn;
  UserPageCallbackFn _userEndPageFn;
  List<String> _routeRegExp = []; // 过滤的路由名称

  /// 初始化AnaPageLoop
  ///
  /// [beginPageFn] 统计页面开始，自定义第三方统计方法，与endPageFn统计配对使用
  ///
  /// [endPageFn] 统计页面结束，自定义第三方统计方法
  ///
  /// [routeRegExp] 自定义需要过滤的路由名称。
  ///
  /// [debug] 是否开启调式模式，输出路由栈信息相关
  init({
    @required UserPageCallbackFn beginPageFn,
    @required UserPageCallbackFn endPageFn,
    List<String> routeRegExp = const [],
    bool debug = true,
  }) {
    if (_initFlag) return;
    _userBeginPageFn = beginPageFn;
    _userEndPageFn = endPageFn;
    _routeRegExp = routeRegExp;

    _streamCtr.stream.listen((routeData) async {
      try {
        if (routeData.name.isNotEmpty &&
            routeData.state == _IRouterState.enter) {
          await _handleEnterState(routeData);
        } else {
          await _handleExitState(routeData);
        }

        if (debug) {
          String text = '';
          for (var i = 0; i < _routeStack.length; i++) {
            if (i != 0) {
              text += ',';
            }
            text +=
                '{name:${_routeStack[i].name}, state: ${_routeStack[i].state}}';
          }
          String logStr = """
当前路由: ${_lastRoute.name}
路由队列栈数量: ${_routeStack.length}
路由队列栈: [$text]""";
          if (_routeStack.length > 100) {
            logStr = """$logStr
警告提示：当前路由长时间未找到结束节点路由，并且路由队列栈数量过多，请正确配置过滤指定路由，降低性能消耗""";
          }

          print("""=====================路由栈信息=====================
$logStr""");
        }
      } catch (e) {
        throw e;
      }
    });
    _initFlag = true;
  }

  /// 路由监听，进入状态的路由数据
  Future<void> _handleEnterState(_IStreamData routeData) async {
    // 初次路由
    if (_lastRoute?.name?.isEmpty ?? true) {
      _lastRoute = routeData;
      await _anaLoopBeginPageFn(routeData.name);
      return;
    }

    _routeStack.add(routeData);
    await _routeLoop();
  }

  /// 处理更新route栈
  Future<void> _routeLoop() async {
    bool loopFlag = false;
    // 更新lastRoute路由信息
    int len = _routeStack.length;
    for (var i = 0; i < len; i++) {
      if (_routeStack[i].state == _IRouterState.exit &&
          _routeStack[i].name == _lastRoute.name) {
        await _anaLoopEndPageFn(_lastRoute.name);
        _lastRoute = _routeStack.removeAt(i);
        loopFlag = true;
        await _anaLoopBeginPageFn(_lastRoute.name);
        break;
      }
    }

    if (loopFlag) await _routeLoop();
  }

  /// 路由监听，退出状态的路由数据
  Future<void> _handleExitState(_IStreamData routeData) async {
    if (_lastRoute.name == routeData.name) {
      await _anaLoopEndPageFn(routeData.name);

      if (_routeStack.length == 0) {
        _lastRoute = _IStreamData();
      } else {
        _lastRoute = _routeStack.removeAt(0);
        await _anaLoopBeginPageFn(_lastRoute.name);
      }
      return;
    }
    // 未匹配压栈
    _routeStack.add(routeData);
  }

  // _delay(Duration timeDur, VoidCallback callback) {
  //   Timer(timeDur.abs(), () => callback());
  // }

  /// 第三方统计开始
  _anaLoopBeginPageFn(String routeName) async {
    assert(_userBeginPageFn != null);
    _userBeginPageFn(routeName);
  }

  /// 第三方统计结束
  _anaLoopEndPageFn(String routeName) async {
    assert(_userEndPageFn != null);
    _userEndPageFn(routeName);
  }

  /// 埋点统计开始
  Future<void> beginPageView(String name) async {
    if (_routeFilter(name)) return;
    _streamCtr.sink.add(_IStreamData(
      name: name,
      state: _IRouterState.enter,
      // time: DateTime.now(),
    ));
  }

  /// 埋点统计结束
  Future<void> endPageView(String name) async {
    if (_routeFilter(name)) return;
    _streamCtr.sink.add(_IStreamData(
      name: name,
      state: _IRouterState.exit,
      // time: DateTime.now(),
    ));
  }

  /// 过滤指定路由名称
  bool _routeFilter(String name) {
    String regStr = ['null', ..._routeRegExp].join('|');
    bool reg = RegExp(r"^(" + regStr + ")").hasMatch(name ?? "null");
    // print('过滤判断>>>${reg}');
    return reg;
  }

  /// 关闭终止流
  close() => _streamCtr.close();

  /// 暂停监听流,可被唤醒
  pause() => _streamCtr.onPause();

  /// 唤醒pause的流
  resume() => _streamCtr.onResume();
}
