import '../../models/tool_type.dart';
import 'tool_context.dart';
import 'word_tool.dart';

class WordValidatorTool implements WordTool {
  @override
  ToolType get type => ToolType.wordValidator;

  @override
  String get title => 'Word Validator';

  @override
  String get hint => 'word e.g. toolkit';

  @override
  bool get requiresDictionary => true;

  @override
  String run(String input, ToolContext context) {
    final candidate = input.trim().toLowerCase();

    if (candidate.isEmpty || !RegExp(r'^[a-z]+$').hasMatch(candidate)) {
      return 'Enter a single word (a-z).';
    }

    return context.dictionarySet.contains(candidate)
        ? 'Confirmed: "$candidate" is in the dictionary.'
        : 'Denied: "$candidate" is not in the dictionary.';
  }
}
