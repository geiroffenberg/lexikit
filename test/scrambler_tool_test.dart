import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexikit/services/tools/scrambler_tool.dart';
import 'package:lexikit/services/tools/tool_context.dart';

void main() {
  group('ScramblerTool', () {
    final tool = ScramblerTool();

    ToolContext makeContext(Set<String> words) {
      return ToolContext(
        dictionaryList: words.toList(growable: false),
        dictionarySet: words,
        random: Random(1),
      );
    }

    test('ignores spaces and returns non-dictionary options only', () {
      final context = makeContext({'planet', 'planetx', 'plante'});

      final result = tool.run('pla net', context);
      final options = result.split('\n');

      expect(options, isNotEmpty);
      expect(options.length, lessThanOrEqualTo(10));
      for (final option in options) {
        expect(option.contains(' '), isFalse);
        expect(option.length, 6);
        expect(option, isNot('planet'));
        expect(context.dictionarySet.contains(option), isFalse);
      }
    });

    test('caps output around 10 options', () {
      final context = makeContext({'lexikit'});

      final result = tool.run('lexikitab', context);
      final options = result.split('\n');

      expect(options.length, lessThanOrEqualTo(10));
      expect(options.length, greaterThanOrEqualTo(1));
    });

    test('validates input', () {
      final context = makeContext({'abc'});

      expect(tool.run('', context), 'Enter text to scramble.');
      expect(tool.run('1a2b', context), 'Use letters and spaces only.');
      expect(tool.run('a', context), 'Enter at least 2 letters.');
    });
  });
}
