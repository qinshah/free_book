// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// typedef F<S extends SfViewState, L extends SfViewLogic> =
//     Widget Function(S state, L logic);

// class SfView<T extends ChangeNotifier> extends StatelessWidget {
//   const SfView(this.f,{super.key});

//   final Widget Function(S state, L logic) f;

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

// class _SfViewState<S extends SfViewState, L extends SfViewLogic<S>>
//     extends State<SfView<S, L>> {
//   @override
//   Widget build(BuildContext context) {}
// }

// abstract class SfViewState {
//   late BuildContext context;
//   SfViewState();
// }

// abstract class SfViewLogic extends ChangeNotifier {
//   void initState() {}

//   @nonVirtual
//   @override
//   void dispose() {
//     super.dispose();
//     rememberDispose();
//   }

//   /// 在这里dispose，目的是为了提醒不要忘记dispose
//   void rememberDispose();
// }
