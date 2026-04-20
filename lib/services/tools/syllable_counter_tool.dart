import '../../models/tool_type.dart';
import 'tool_context.dart';
import 'word_tool.dart';
import 'word_tool_utils.dart';

class SyllableCounterTool implements WordTool {
  @override
  ToolType get type => ToolType.syllableCounter;

  @override
  String get title => 'Syllable Counter';

  @override
  String get hint => 'sentence or paragraph';

  @override
  bool get requiresDictionary => false;

  @override
  String run(String input, ToolContext context) {
    final normalized = input.trim();
    if (normalized.isEmpty) return 'Syllables: 0';

    final tokens = RegExp(r"[a-zA-Z]+(?:'[a-zA-Z]+)?")
      .allMatches(normalized.toLowerCase())
        .map((m) => m.group(0)!)
        .toList();

    if (tokens.isEmpty) return 'Syllables: 0';
    final total = tokens.map(estimateSyllables).fold<int>(0, (sum, value) => sum + value);
    return 'Estimated syllables: $total';
  }
}
