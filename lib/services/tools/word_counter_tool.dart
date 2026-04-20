import '../../models/tool_type.dart';
import 'tool_context.dart';
import 'word_tool.dart';

class WordCounterTool implements WordTool {
  @override
  ToolType get type => ToolType.wordCounter;

  @override
  String get title => 'Word Counter';

  @override
  String get hint => 'sentence or paragraph';

  @override
  bool get requiresDictionary => false;

  @override
  String run(String input, ToolContext context) {
    final normalized = input.trim();
    if (normalized.isEmpty) return 'Word count: 0';

    final words = RegExp(r"[a-zA-Z]+(?:'[a-zA-Z]+)?").allMatches(normalized).length;
    return 'Word count: $words';
  }
}
