// import 'package:flutter/widgets.dart';

// class CachedIndexStack extends StatefulWidget {
//   final int index;

//   final List<Widget> children;

//   const CachedIndexStack({
//     super.key,
//     required this.index,
//     required this.children,
//   });

//   @override
//   State<CachedIndexStack> createState() => _CachedIndexStackState();
// }

// class _CachedIndexStackState extends State<CachedIndexStack> {
//   late final _cacheds = List.filled(widget.children.length, false);
//   @override
//   Widget build(BuildContext context) {
//     return IndexedStack(index: widget.index, children: widget.children);
//   }
// }
