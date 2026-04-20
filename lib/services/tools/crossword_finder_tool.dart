import '../../models/tool_type.dart';
import 'tool_context.dart';
import 'word_tool.dart';

class CrosswordFinderTool implements WordTool {
  @override
  ToolType get type => ToolType.crosswordFinder;

  @override
  String get title => 'Crossword Finder';

  @override
  String get hint => 'pattern e.g. c??t or c-a?';

  @override
  bool get requiresDictionary => true;

  @override
  String run(String input, ToolContext context) {
    final pattern = input.trim().toLowerCase();
    if (pattern.isEmpty || !RegExp(r'^[a-z_?*\-]+$').hasMatch(pattern)) {
      return 'Use letters with *, _, or ? as wildcards. Hyphen (-) stays literal.';
    }

    final escaped = pattern
        .replaceAllMapped(RegExp(r'[.^$+(){}\[\]|\\]'), (m) => '\\${m[0]}')
        .replaceAll('?', '.')
        .replaceAll('_', '.')
        .replaceAll('*', '.');

    final regex = RegExp('^$escaped\$');
    final matches = context.dictionaryList.where((word) => regex.hasMatch(word)).toSet().toList()..sort();

    if (matches.isEmpty) return 'No crossword matches found.';
    return matches.join('\n');
  }
}
