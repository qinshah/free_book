import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef StateViewBuilder<StateT extends StateModel, LogicT extends Logic> =
    Widget Function(BuildContext context, StateT state, LogicT logic);

class StateBuilder<StateT extends StateModel> extends StatelessWidget {
  const StateBuilder({super.key, required this.logic, required this.builder});

  final Logic<StateT> logic;

  final StateViewBuilder<StateT, Logic<StateT>> builder;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Logic<StateT>>(
      create: (context) => logic,
      child: builder(context, logic.state, logic),
    );
  }
}

abstract class StateModel {
  const StateModel();
}

abstract class Logic<T extends StateModel> extends ChangeNotifier {
  T state;
  Logic(this.state);

  void rebuildView(T newState) {
    state = newState;
    notifyListeners();
  }
}
