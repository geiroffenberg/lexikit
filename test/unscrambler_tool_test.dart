import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexikit/services/tools/tool_context.dart';
import 'package:lexikit/services/tools/unscrambler_tool.dart';

void main() {
  group('UnscramblerTool', () {
    final tool = UnscramblerTool();

    ToolContext makeContext(Set<String> words) {
      return ToolContext(
        dictionaryList: words.toList(growable: false),
        dictionarySet: words,
        random: Random(1),
      );
    }

    test('returns only exact-length matches', () {
      final context = makeContext({
        'planet',
        'panel',
        'plane',
        'pan',
        'let',
        'le',
        'net',
        'ant',
        'tan',
      });

      final result = tool.run('planet', context);

      expect(result, 'planet');
    });

    test('sorts exact-length matches alphabetically', () {
      final context = makeContext({
        'ratel',
        'alter',
        'alert',
        'later',
        'art',
      });

      final result = tool.run('later', context);

      expect(result.split('\n'), ['alert', 'alter', 'later', 'ratel']);
    });

    test('returns no words found when no exact match exists', () {
      final context = makeContext({'pan', 'tan', 'ant'});

      final result = tool.run('planet', context);

      expect(result, 'No words found.');
    });
  });
}
