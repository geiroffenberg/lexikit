import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexikit/services/tools/tool_context.dart';
import 'package:lexikit/services/tools/word_validator_tool.dart';

void main() {
  group('WordValidatorTool', () {
    final tool = WordValidatorTool();

    ToolContext makeContext(Set<String> words) {
      return ToolContext(
        dictionaryList: words.toList(growable: false),
        dictionarySet: words,
        random: Random(1),
      );
    }

    test('confirms word that exists in dictionary', () {
      final context = makeContext({'apple', 'banana', 'toolkit'});

      final result = tool.run('toolkit', context);

      expect(result, 'Confirmed: "toolkit" is in the dictionary.');
    });

    test('denies word that does not exist in dictionary', () {
      final context = makeContext({'apple', 'banana', 'toolkit'});

      final result = tool.run('orbit', context);

      expect(result, 'Denied: "orbit" is not in the dictionary.');
    });

    test('normalizes uppercase input before checking dictionary', () {
      final context = makeContext({'apple', 'banana', 'toolkit'});

      final result = tool.run('ToOlKiT', context);

      expect(result, 'Confirmed: "toolkit" is in the dictionary.');
    });

    test('rejects empty and non-letter input', () {
      final context = makeContext({'apple', 'banana', 'toolkit'});

      expect(tool.run('', context), 'Enter a single word (a-z).');
      expect(tool.run('two words', context), 'Enter a single word (a-z).');
      expect(tool.run('abc123', context), 'Enter a single word (a-z).');
    });
  });
}
