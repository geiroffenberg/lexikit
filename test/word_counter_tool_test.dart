import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexikit/services/tools/tool_context.dart';
import 'package:lexikit/services/tools/word_counter_tool.dart';

void main() {
  group('WordCounterTool', () {
    final tool = WordCounterTool();
    final context = ToolContext(
      dictionaryList: const [],
      dictionarySet: const {},
      random: Random(1),
    );

    test('counts basic words', () {
      expect(tool.run('hello world from lexikit', context), 'Word count: 4');
    });

    test('handles punctuation and apostrophes', () {
      expect(tool.run("Don't stop, won't stop.", context), 'Word count: 4');
    });

    test('returns zero for empty input', () {
      expect(tool.run('   ', context), 'Word count: 0');
    });
  });
}
