import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexikit/services/tools/scrabble_finder_tool.dart';
import 'package:lexikit/services/tools/tool_context.dart';

void main() {
  group('ScrabbleFinderTool', () {
    final tool = ScrabbleFinderTool();

    ToolContext makeContext(Set<String> words) {
      return ToolContext(
        dictionaryList: words.toList(growable: false),
        dictionarySet: words,
        random: Random(1),
      );
    }

    test('finds all words of any length (min 2) from input letters', () {
      final context = makeContext({'planet', 'panel', 'plane', 'pan', 'let', 'le', 'net', 'ant', 'tan', 'a', 'n'});
      final result = tool.run('planet', context);
      final lines = result.split('\n');
      expect(lines, containsAll(['planet', 'panel', 'plane', 'pan', 'let', 'net', 'ant', 'tan']));
      expect(lines, isNot(contains('a')));
      expect(lines, isNot(contains('n')));
    });

    test('returns no words for input with no matches', () {
      final context = makeContext({'dog', 'cat'});
      final result = tool.run('zzz', context);
      expect(result, 'No words found.');
    });

    test('rejects invalid input', () {
      final context = makeContext({'dog', 'cat'});
      expect(tool.run('123', context), 'Enter letters only (a-z).');
      expect(tool.run('', context), 'Enter letters only (a-z).');
    });
  });
}
