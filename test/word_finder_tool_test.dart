import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexikit/services/tools/tool_context.dart';
import 'package:lexikit/services/tools/word_finder_tool.dart';

void main() {
  group('WordFinderTool', () {
    final tool = WordFinderTool();

    ToolContext makeContext(Set<String> words) {
      return ToolContext(
        dictionaryList: words.toList(growable: false),
        dictionarySet: words,
        random: Random(1),
      );
    }

    test('finds all words of any length (min 2) from input letters', () {
      final context = makeContext({
        'planet', 'panel', 'plane', 'pan', 'let', 'le', 'net', 'ant', 'tan',
        'a', 'n',
      });
      final result = tool.run('planet', context);
      final lines = result.split('\n');
      expect(lines, containsAll([
        'planet (8)', 'panel (7)', 'plane (7)', 'tan (3)', 'ant (3)', 'net (3)', 'let (3)',
      ]));
      // No single letters in output.
      expect(lines.any((l) => l == 'a' || l == 'n' || l.startsWith('a (') || l.startsWith('n (')),
          isFalse);
    });

    test('exact:N limits to a single length', () {
      final context = makeContext({
        'planet', 'panel', 'plane', 'plan', 'planeta', 'net', 'ten',
      });
      final result = tool.run('planet exact:5', context);
      final words =
          result.split('\n').map((w) => w.split(' ').first).toList();
      expect(words, ['panel', 'plane']);
    });

    test('starts/ends filters narrow results', () {
      final context = makeContext({'planet', 'plan', 'lane', 'ten', 'tan'});
      final starts = tool.run('planeton starts:pl', context)
          .split('\n').map((w) => w.split(' ').first).toList();
      expect(starts, containsAll(['planet', 'plan']));
      expect(starts, isNot(contains('lane')));

      final ends = tool.run('planet ends:et', context)
          .split('\n').map((w) => w.split(' ').first).toList();
      expect(ends, contains('planet'));
      expect(ends, isNot(contains('tan')));
    });

    test('sorts by Scrabble points descending', () {
      final context = makeContext({'quiz', 'zoo', 'cat', 'quizzy', 'zz'});
      final result = tool.run('quizzyzoo', context);
      final lines = result.split('\n');
      // quizzy (high Q/Z) scores most, zoo (12) next, etc.
      expect(int.parse(lines[0].split('(')[1].split(')')[0]),
          greaterThan(int.parse(lines[1].split('(')[1].split(')')[0])));
    });

    test('space-separated filters do not count as wildcards', () {
      final context = makeContext({'plane', 'plant', 'plate', 'panel', 'net'});
      final result = tool.run('planet exact:5 starts:pl', context);
      final words =
          result.split('\n').map((w) => w.split(' ').first).toList();
      expect(words, containsAll(['plane', 'plant', 'plate']));
      expect(words, isNot(contains('panel'))); // does not start with "pl"
      expect(words, isNot(contains('net'))); // wrong length
    });

    test('rejects input that is not letters', () {
      final context = makeContext({'dog', 'cat'});
      expect(tool.run('123', context), contains('letters'));
      expect(tool.run('', context), contains('letters'));
      expect(tool.run('readt exact:five', context), contains('positive'));
    });

    test('returns no words found when nothing matches', () {
      final context = makeContext({'dog', 'cat'});
      expect(tool.run('zzz', context), 'No words found.');
    });
  });
}
