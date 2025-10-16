import 'package:flutter/material.dart';
import 'package:free_book/function/state_management.dart';

class EditPageState extends ViewState {
  final saveAsNameCntlr = TextEditingController();
  String? docPath;
  String docName = '新建';
}
