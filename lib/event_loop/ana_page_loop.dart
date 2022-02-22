import 'dart:async';
import 'dart:collection';

enum _IRouterState {
  /// 页面进入
  enter,

  /// 页面离开
  exit,
}

class _IStreamData {
  /// 路由名称
  String? name;

  /// 路由状态
  _IRouterState? state;

  /// 时间
  DateTime? time;

  _IStreamData({this.name, this.state, this.time});
}

AnaPageLoop anaPageLoop = AnaPageLoop();

typedef void UserPageCallbackFn(String routerName);

class AnaPageLoop {
  bool _initFlag = false;
  bool _debug = false;
  _IStreamData _lastRoute = _IStreamData(); // 上一次路由
  List<_IStreamData> _routeStack = []; // 路由栈
  StreamController<_IStreamData> _streamCtr = StreamController<_IStreamData>();
  late UserPageCallbackFn _userBeginPageFn;
  late UserPageCallbackFn _userEndPageFn;
  List<String> _routeRegExp = []; // 过滤的路由名称
  SplayTreeMap<String, String> _routeNameDic = SplayTreeMap<String, String>();

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
    required UserPageCallbackFn beginPageFn,
    required UserPageCallbackFn endPageFn,
    List<String> routeRegExp = const [],
    bool debug = false,
    Map<String, String> routeName = const {},
  }) {
    if (_initFlag) return;
    _userBeginPageFn = beginPageFn;
    _userEndPageFn = endPageFn;
    _routeRegExp = routeRegExp;
    _debug = debug;

    if (routeName.isNotEmpty) {
      _routeNameDic.addAll(routeName);
    }

    _streamCtr.stream.listen(_streamCtrListen);
    _initFlag = true;
  }

  // loop流监听
  _streamCtrListen(_IStreamData routeData) async {
    try {
      if (routeData.name != null && routeData.state == _IRouterState.enter) {
        await _handleEnterState(routeData);
      } else {
        await _handleExitState(routeData);
      }

      if (_debug) {
        String _tagTitle =
            (routeData.state == _IRouterState.enter) ? '进栈' : '出栈';
        String text = '';
        final _len = _routeStack.length;
        for (var i = 0; i < _len; i++) {
          if (i != 0) {
            text += ',';
          }
          text +=
              '{name:${_routeStack[i].name}, state: ${_routeStack[i].state}}';
        }
        String logStr = """
当前路由: ${_lastRoute.name}
$_tagTitle 信息：name: ${routeData.name}, state: ${routeData.state}
路由队列栈数量: ${_routeStack.length}
路由队列栈: [$text]""";
        if (_routeStack.length > 100) {
          logStr = """$logStr
警告提示：当前路由长时间未找到结束节点路由，并且路由队列栈数量过多，请正确配置过滤指定路由，降低性能消耗""";
        }
        print("""=====================路由栈信息($_tagTitle)=====================
$logStr""");
      }
    } catch (e) {
      if (_debug) print(e);
    }
  }

  /// 路由监听，进入状态的路由数据
  Future<void> _handleEnterState(_IStreamData routeData) async {
    // 初次路由
    if (_lastRoute.name?.isEmpty ?? true) {
      _lastRoute = routeData;
      await _anaLoopBeginPageFn(routeData.name);
      return;
    }

    _routeStack.add(routeData);
    // 容错
    if (_routeStack.length < 2) {
      for (var i = 0; i < _routeStack.length; i++) {
        if (_routeStack[i].state == _IRouterState.enter &&
            _lastRoute.name == _routeStack[i].name) {
          _routeStack.removeAt(i); // 移除相同
          break;
        }
      }
    }
  }

  /// 路由监听，退出状态的路由数据
  Future<void> _handleExitState(_IStreamData routeData) async {
    _routeStack.add(routeData);
    await _routeExitLoop();
  }

  Future<void> _routeExitLoop() async {
    bool loopFlag = false;
    int len = _routeStack.length;
    for (var i = 0; i < len; i++) {
      if (_routeStack[i].state == _IRouterState.exit &&
          _routeStack[i].name == _lastRoute.name) {
        // 结束当前栈
        _routeStack.removeAt(i);
        await _anaLoopEndPageFn(_lastRoute.name!);
        await _updataLastRoute(); // 更新当前栈
        loopFlag = true;
        break;
      }
    }

    if (loopFlag) await _routeExitLoop();
  }

  /// 更新lastRoute路由信息
  Future<void> _updataLastRoute() async {
    final int len = _routeStack.length;
    if (len == 0) {
      _lastRoute = _IStreamData();
    }
    for (var i = 0; i < len; i++) {
      if (_routeStack[i].state == _IRouterState.enter) {
        _lastRoute = _routeStack.removeAt(i);
        await _anaLoopBeginPageFn(_lastRoute.name);
        break;
      }
    }
  }

  // _delay(Duration timeDur, VoidCallback callback) {
  //   Timer(timeDur.abs(), () => callback());
  // }

  /// 第三方统计开始
  _anaLoopBeginPageFn(String? routeName) async {
    _userBeginPageFn(routeName!);
  }

  /// 第三方统计结束
  Future<void> _anaLoopEndPageFn(String routeName) async {
    _userEndPageFn(routeName);
  }

  /// 埋点统计开始
  Future<void> beginPageView(String name) async {
    if (_routeFilter(name) ||
        !_streamCtr.hasListener ||
        _lastRoute.name == name) return;
    _streamCtr.sink.add(_IStreamData(
      name: _routeNameDic[name] ?? name,
      state: _IRouterState.enter,
      // time: DateTime.now(),
    ));
  }

  /// 埋点统计结束
  Future<void> endPageView(String name) async {
    if (_routeFilter(name) || !_streamCtr.hasListener) return;
    _streamCtr.sink.add(_IStreamData(
      name: _routeNameDic[name] ?? name,
      state: _IRouterState.exit,
      // time: DateTime.now(),
    ));
  }

  /// 过滤指定路由名称
  bool _routeFilter(String name) {
    String regStr = ['null', ..._routeRegExp].join('|');
    bool reg = RegExp(r"^(" + regStr + ")").hasMatch(name);
    return reg;
  }

  /// 关闭anaPageLoop监听流，关闭后不在处理任何事件，不可在次恢复流
  close() => _streamCtr.close();

  /// 临时暂停anaPageLoop监听流，可被唤醒
  pause() => _streamCtr.onPause!();

  /// 唤醒anaPageLoop流
  resume() => _streamCtr.onResume!();
}
