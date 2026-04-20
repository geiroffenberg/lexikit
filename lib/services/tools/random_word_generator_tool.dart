import 'dart:math';

import '../../models/tool_type.dart';
import 'tool_context.dart';
import 'word_tool.dart';

class RandomWordGeneratorTool implements WordTool {
  @override
  ToolType get type => ToolType.randomWordGenerator;

  @override
  String get title => 'Random Word Generator';

  @override
  String get hint => 'length number e.g. 7';

  @override
  bool get requiresDictionary => true;

  @override
  String run(String input, ToolContext context) {
    final lengthText = input.trim();
    if (lengthText.isEmpty) {
      return 'Enter a target word length (number).';
    }

    final targetLength = int.tryParse(lengthText);
    if (targetLength == null || targetLength <= 0) {
      return 'Enter a valid positive number.';
    }

    final pool = context.dictionaryList.where((word) => word.length == targetLength).toList();

    if (pool.isEmpty) {
      return 'No words found for that length.';
    }

    // Randomize order first, then pick words that maximize letter diversity.
    final shuffledPool = List<String>.from(pool)..shuffle(context.random);
    final targetCount = min(10, shuffledPool.length);
    final picks = <String>[];
    final usedLetters = <String>{};

    while (picks.length < targetCount) {
      String? bestWord;
      var bestNewLetters = -1;

      for (final word in shuffledPool) {
        if (picks.contains(word)) continue;

        final wordLetters = word.split('').toSet();
        final newLetters = wordLetters.where((letter) => !usedLetters.contains(letter)).length;

        if (newLetters > bestNewLetters) {
          bestNewLetters = newLetters;
          bestWord = word;
          if (bestNewLetters == wordLetters.length) {
            break;
          }
        }
      }

      if (bestWord == null) {
        break;
      }

      picks.add(bestWord);
      usedLetters.addAll(bestWord.split(''));
    }

    return picks.join('\n');
  }
}
