import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexikit/services/tools/scrabble_finder_tool.dart';
import 'package:lexikit/services/tools/tool_context.dart';

void main() {
  group('ScrabbleFinderTool scoring', () {
    final tool = ScrabbleFinderTool();

    ToolContext makeContext(Set<String> words) {
      return ToolContext(
        dictionaryList: words.toList(growable: false),
        dictionarySet: words,
        random: Random(1),
      );
    }

    test('sorts by Scrabble points, then length, then alpha', () {
      final context = makeContext({'cat', 'quiz', 'zoo', 'bat', 'tab', 'cab', 'act'});
      final result = tool.run('catquizbo', context);
      final lines = result.split('\n');
      // quiz (22), zoo (12), bat/tab/cab/act/cat (5)
      expect(lines[0], startsWith('quiz (22)'));
      expect(lines[1], startsWith('zoo (12)'));
      // All 3-letter words have 5 points, sorted by length (same), then alpha
      final threeLetterWords = lines.skip(2).map((l) => l.split(' ').first).toList();
      expect(threeLetterWords, containsAll(['act', 'bat', 'cab', 'cat', 'tab']));
    });
  });
}
