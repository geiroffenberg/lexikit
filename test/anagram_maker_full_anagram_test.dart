import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexikit/services/tools/anagram_maker_tool.dart';
import 'package:lexikit/services/tools/tool_context.dart';

void main() {
  group('AnagramMakerTool full anagram mode', () {
    final tool = AnagramMakerTool();

    ToolContext makeContext(Set<String> words) {
      return ToolContext(
        dictionaryList: words.toList(growable: false),
        dictionarySet: words,
        random: Random(1),
      );
    }

    test('finds all full anagrams (single and multi-word)', () {
      final context = makeContext({'rat', 'tar', 'art', 'listen', 'silent', 'enlist', 'tinsel', 'inlets', 'ten', 'list', 'en', 'tile', 'let', 'is', 'net', 'sit', 'tile', 'tie', 'a', 't'});
      final result = tool.run('listen rat', context);
      final lines = result.split('\n');
      expect(lines.first, contains('All possible anagrams using all letters'));
      // Should include multi-word and single word anagrams
      expect(lines.skip(1), anyElement(contains('listen rat')));
      expect(lines.skip(1), anyElement(contains('silent rat')));
      expect(lines.skip(1), anyElement(contains('tinsel rat')));
      expect(lines.skip(1), anyElement(contains('enlist rat')));
      // Should include multi-word splits
      expect(lines.skip(1), anyElement(contains('rat listen')));
      // Should not include partial anagrams
      expect(lines.skip(1), everyElement((s) => s.replaceAll(' ', '').length == 'listenrat'.length));
    });

    test('returns no full anagrams if impossible', () {
      final context = makeContext({'rat', 'tar', 'art'});
      final result = tool.run('xyz abc', context);
      expect(result, 'No full anagrams found.');
    });

    test('rejects invalid input', () {
      final context = makeContext({'rat', 'tar', 'art'});
      expect(tool.run('rat 123', context), contains('For sentence anagram mode'));
    });
  });
}
