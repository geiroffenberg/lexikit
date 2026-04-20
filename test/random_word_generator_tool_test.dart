import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexikit/services/tools/random_word_generator_tool.dart';
import 'package:lexikit/services/tools/tool_context.dart';

void main() {
  group('RandomWordGeneratorTool', () {
    final tool = RandomWordGeneratorTool();

    ToolContext makeContext(List<String> words) {
      final set = words.toSet();
      return ToolContext(
        dictionaryList: words,
        dictionarySet: set,
        random: Random(1),
      );
    }

    test('requires a numeric length input', () {
      final context = makeContext(['cat', 'dog', 'sun']);

      expect(tool.run('', context), 'Enter a target word length (number).');
      expect(tool.run('abc', context), 'Enter a valid positive number.');
      expect(tool.run('0', context), 'Enter a valid positive number.');
    });

    test('returns up to 10 words of requested length', () {
      final words = <String>[
        'stone',
        'crane',
        'flint',
        'broad',
        'chime',
        'proud',
        'gleam',
        'shark',
        'vocal',
        'nymph',
        'zebra',
        'quilt',
      ];
      final context = makeContext(words);

      final result = tool.run('5', context);
      final lines = result.split('\n');

      expect(lines.length, lessThanOrEqualTo(10));
      expect(lines.length, greaterThanOrEqualTo(1));
      for (final word in lines) {
        expect(word.length, 5);
      }
    });

    test('returns no words message for unsupported length', () {
      final context = makeContext(['cat', 'dog', 'sun']);

      final result = tool.run('8', context);

      expect(result, 'No words found for that length.');
    });
  });
}
