import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexikit/services/tools/crossword_finder_tool.dart';
import 'package:lexikit/services/tools/tool_context.dart';

void main() {
  group('CrosswordFinderTool', () {
    final tool = CrosswordFinderTool();

    ToolContext makeContext(Set<String> words) {
      return ToolContext(
        dictionaryList: words.toList(growable: false),
        dictionarySet: words,
        random: Random(1),
      );
    }

    test('treats *, _, and ? all as single-character wildcards', () {
      final context = makeContext({'cat', 'cot', 'cut', 'cast', 'coat'});

      final star = tool.run('c*t', context).split('\n');
      final underscore = tool.run('c_t', context).split('\n');
      final question = tool.run('c?t', context).split('\n');

      expect(star, ['cat', 'cot', 'cut']);
      expect(underscore, ['cat', 'cot', 'cut']);
      expect(question, ['cat', 'cot', 'cut']);
    });

    test('keeps hyphen literal in pattern matching', () {
      final context = makeContext({'co-op', 'coop', 'co-ops'});

      final result = tool.run('co-?p', context);

      expect(result.split('\n'), ['co-op']);
    });

    test('returns no matches message when pattern yields none', () {
      final context = makeContext({'cat', 'cot', 'cut'});

      final result = tool.run('z??', context);

      expect(result, 'No crossword matches found.');
    });

    test('rejects invalid symbols in pattern', () {
      final context = makeContext({'cat'});

      final result = tool.run('c@t', context);

      expect(result, 'Use letters with *, _, or ? as wildcards. Hyphen (-) stays literal.');
    });
  });
}
