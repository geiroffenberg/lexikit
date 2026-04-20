import '../../models/tool_type.dart';
import 'tool_context.dart';

abstract class WordTool {
  ToolType get type;
  String get title;
  String get hint;
  bool get requiresDictionary;

  String run(String input, ToolContext context);
}
