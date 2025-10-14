import '../../function/logic_builder.dart';

class EditPageState extends StateModel {
  final String? filePath;
  const EditPageState({this.filePath});
  const EditPageState.empty() : filePath = null;
}
