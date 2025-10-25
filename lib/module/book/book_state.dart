import 'package:flutter/material.dart';
import 'package:free_book/function/state_management.dart';

class BookState extends ViewState {
  final saveAsNameCntlr = TextEditingController();
  String? filePath;
  String name = '空白文档';

  bool saved = true;
}
