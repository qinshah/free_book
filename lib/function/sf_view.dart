import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef F<S extends SfViewState, L extends SfViewLogic> = Widget Function(
    S state, L logic);

class SfView<S extends SfViewState, L extends SfViewLogic<S>>
    extends StatelessWidget {
  const SfView(this.f, {super.key});

  final F<S, L> f;

  @override
  Widget build(BuildContext context) {
    final logic = context.watch<L>();
    return f(logic.state, logic);
  }
}

abstract class SfViewState {}

abstract class SfViewLogic<S extends SfViewState> extends ChangeNotifier {
  S state;

  SfViewLogic(this.state);

  @nonVirtual
  @override
  void dispose() {
    super.dispose();
    rememberDispose();
  }

  /// 在这里dispose，目的是为了提醒不要忘记dispose
  void rememberDispose();
}
