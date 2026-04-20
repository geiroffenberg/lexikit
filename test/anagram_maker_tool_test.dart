import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexikit/services/tools/anagram_maker_tool.dart';
import 'package:lexikit/services/tools/tool_context.dart';

void main() {
  group('AnagramMakerTool', () {
    final tool = AnagramMakerTool();

    ToolContext makeContext(Set<String> words) {
      return ToolContext(
        dictionaryList: words.toList(growable: false),
        dictionarySet: words,
        random: Random(1),
      );
    }

    test('single-word mode returns all anagrams as a list', () {
      final context = makeContext({'listen', 'silent', 'enlist', 'inlets', 'tinsel'});

      final result = tool.run('listen', context);
      final lines = result.split('\n');

      expect(lines, ['enlist', 'inlets', 'silent', 'tinsel']);
    });

    test('sentence mode explains behavior and returns sentence anagrams', () {
      final context = makeContext({
        'listen',
        'silent',
        'enlist',
        'art',
        'rat',
        'tar',
      });

      final result = tool.run('listen art', context);
      final lines = result.split('\n');

      expect(lines.first, 'This is a sentence. Each word will be an anagram.');
      expect(lines.length, greaterThan(1));
      expect(lines.skip(1), contains('enlist rat'));
      expect(lines.skip(1), contains('silent tar'));
    });

    test('sentence mode reports when no sentence is possible', () {
      final context = makeContext({'listen', 'silent', 'enlist'});

      final result = tool.run('listen xyz', context);

      expect(result, 'This is a sentence. Each word will be an anagram.\nNo sentences possible.');
    });

    test('rejects non-letter symbols', () {
      final context = makeContext({'listen', 'silent', 'enlist'});

      expect(tool.run('list-en', context), 'Enter letters only (a-z).');
      expect(tool.run('listen art!', context), 'For sentence mode, use letters and spaces only.');
    });
  });
}
