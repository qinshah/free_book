import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class ViewState {}

abstract class Logic<T extends ViewState> {
  static final _values = <String, Logic>{};

  static LT find<LT extends Logic>() {
    final key = LT.toString();
    assert(
      _values.containsKey(key),
      '没有找到$key\n1、确认你指定了泛型参数\n2、确认在组件树上方创建过\n3、确认没有在创建处的super.initState()之前调用',
    );
    return _values[key] as LT;
  }

  late final void Function(VoidCallback fn) setState;
  late final void Function(Logic logic) update;
  T state;
  Logic(this.state) {
    final key = runtimeType.toString();
    print('logic($key)实例化');
    if (_values.containsKey(key)) print('警告⚠️：logic($key)被重复实例化');
    _values[key] = this;
  }

  void rebuild(T newState) {
    setState(() => state = newState);
  }

  void dispose();
}

mixin LogicMix<STF extends StatefulWidget, T extends Logic> on State<STF> {
  late final T logic = createLogic();

  T createLogic();

  @override
  void initState() {
    super.initState();
    logic.setState = setState;
  }

  /// 在ligic中实现
  @nonVirtual
  @override
  void dispose() {
    super.dispose();
    Logic._values.remove(logic.runtimeType.toString());
    logic.dispose();
  }
}
