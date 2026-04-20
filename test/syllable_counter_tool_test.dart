import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexikit/services/tools/syllable_counter_tool.dart';
import 'package:lexikit/services/tools/tool_context.dart';

void main() {
  group('SyllableCounterTool', () {
    final tool = SyllableCounterTool();
    final context = ToolContext(
      dictionaryList: const [],
      dictionarySet: const {},
      random: Random(1),
    );

    test('returns estimated syllables for sentence', () {
      final result = tool.run('hello world', context);
      expect(result, 'Estimated syllables: 3');
    });

    test('handles punctuation and apostrophes', () {
      final result = tool.run("Don't panic!", context);
      expect(result, 'Estimated syllables: 3');
    });

    test('returns zero for empty input', () {
      expect(tool.run('   ', context), 'Syllables: 0');
    });
  });
}
