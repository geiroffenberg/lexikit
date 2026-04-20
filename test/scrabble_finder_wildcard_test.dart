import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexikit/services/tools/scrabble_finder_tool.dart';
import 'package:lexikit/services/tools/tool_context.dart';

void main() {
  group('ScrabbleFinderTool wildcards', () {
    final tool = ScrabbleFinderTool();

    ToolContext makeContext(Set<String> words) {
      return ToolContext(
        dictionaryList: words.toList(growable: false),
        dictionarySet: words,
        random: Random(1),
      );
    }

    test('finds words with one wildcard', () {
      final context = makeContext({'cat', 'cot', 'cut', 'coat', 'cast', 'act', 'tac'});
      final result = tool.run('ct_', context);
      final lines = result.split('\n');
      expect(lines, containsAll(['cat', 'cot', 'cut', 'act', 'tac']));
      expect(lines, isNot(contains('coat'))); // needs 4 letters
    });

    test('finds words with multiple wildcards', () {
      final context = makeContext({'cat', 'coat', 'taco', 'act', 'tac', 'at'});
      final result = tool.run('c _ *', context);
      final lines = result.split('\n');
      expect(lines, containsAll(['cat', 'coat', 'taco', 'act', 'tac', 'at']));
    });

    test('wildcards can be space, _, *, ?', () {
      final context = makeContext({'cat', 'cot', 'cut', 'act'});
      expect(tool.run('c t ?', context).split('\n'), contains('cat'));
      expect(tool.run('c t *', context).split('\n'), contains('cat'));
      expect(tool.run('c t _', context).split('\n'), contains('cat'));
      expect(tool.run('c t  ', context).split('\n'), contains('cat'));
    });

    test('rejects invalid input', () {
      final context = makeContext({'cat'});
      expect(tool.run('c@t', context), contains('Enter letters and wildcards only'));
    });
  });
}
