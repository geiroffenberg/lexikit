import '../../models/tool_type.dart';
import 'tool_context.dart';
import 'word_tool.dart';
import 'word_tool_utils.dart';

class ScrabbleFinderTool implements WordTool {
  @override
  ToolType get type => ToolType.scrabbleFinder;

  @override
  String get title => 'Scrabble Finder';

  @override
  String get hint => 'letters e.g. readt';

  @override
  bool get requiresDictionary => true;

  @override
  String run(String input, ToolContext context) {
    final normalized = input.trim().toLowerCase();
      if (normalized.isEmpty || RegExp(r'[^a-z _*?]').hasMatch(normalized)) {
        return 'Enter letters and wildcards only (a-z, space, _, *, ?).';
      }

    // Count wildcards: space, _, *, ?
    final wildcardMatches = RegExp(r'[ _*?]').allMatches(normalized);
    final wildcardCount = wildcardMatches.length;
    if (wildcardCount > 2) {
      return 'Maximum 2 wildcards (blank tiles) allowed in Scrabble.';
    }
    final lettersOnly = normalized.replaceAll(RegExp(r'[ _*?]'), '');
    final bag = letterCounts(lettersOnly);

    final matches = context.dictionaryList
      .where((word) => word.length > 1 && _canBuildWithWildcards(word, bag, wildcardCount))
      .toSet()
      .toList();
    if (matches.isEmpty) return 'No words found.';
    // Sort by Scrabble points, then by length (desc), then alphabetically
    matches.sort((a, b) {
      final pa = scrabbleScore(a);
      final pb = scrabbleScore(b);
      if (pa != pb) return pb.compareTo(pa);
      if (a.length != b.length) return b.length.compareTo(a.length);
      return a.compareTo(b);
    });
    const maxResults = 220;
    return matches.take(maxResults).map((w) => '$w (${scrabbleScore(w)})').join('\n');
  }

  // Returns true if word can be built from bag + up to wildcardCount blanks
  bool _canBuildWithWildcards(String word, Map<String, int> bag, int wildcardCount) {
    final needed = <String, int>{};
    for (final ch in word.split('')) {
      needed[ch] = (needed[ch] ?? 0) + 1;
    }
    int wildsLeft = wildcardCount;
    for (final entry in needed.entries) {
      final have = bag[entry.key] ?? 0;
      if (have < entry.value) {
        final missing = entry.value - have;
        wildsLeft -= missing;
        if (wildsLeft < 0) return false;
      }
    }
    return true;
  }

  int scrabbleScore(String word) {
    // Standard English Scrabble letter values
    const scores = {
      'a': 1, 'e': 1, 'i': 1, 'o': 1, 'u': 1, 'l': 1, 'n': 1, 's': 1, 't': 1, 'r': 1,
      'd': 2, 'g': 2,
      'b': 3, 'c': 3, 'm': 3, 'p': 3,
      'f': 4, 'h': 4, 'v': 4, 'w': 4, 'y': 4,
      'k': 5,
      'j': 8, 'x': 8,
      'q': 10, 'z': 10,
    };
    var total = 0;
    for (final ch in word.split('')) {
      total += scores[ch] ?? 0;
    }
    return total;
  }
}
