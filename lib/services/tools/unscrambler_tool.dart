import '../../models/tool_type.dart';
import 'tool_context.dart';
import 'word_tool.dart';
import 'word_tool_utils.dart';

class UnscramblerTool implements WordTool {
  @override
  ToolType get type => ToolType.unscrambler;

  @override
  String get title => 'Unscrambler';

  @override
  String get hint => 'letters e.g. readt';

  @override
  bool get requiresDictionary => true;

  @override
  String run(String input, ToolContext context) {
    if (input.isEmpty || !RegExp(r'^[a-z]+$').hasMatch(input)) {
      return 'Enter letters only (a-z).';
    }

    final bag = letterCounts(input);
    final matches = context.dictionaryList
      .where((word) => word.length == input.length)
        .where((word) => canBuildWord(word, bag))
        .toSet()
        .toList();

    matches.sort(_byLengthThenAlphabet);

    if (matches.isEmpty) return 'No words found.';

    const maxResults = 220;
    return matches.take(maxResults).join('\n');
  }

  int _byLengthThenAlphabet(String a, String b) {
    final lengthOrder = b.length.compareTo(a.length);
    if (lengthOrder != 0) return lengthOrder;
    return a.compareTo(b);
  }
}
