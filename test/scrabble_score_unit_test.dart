import 'package:flutter_test/flutter_test.dart';
import 'package:lexikit/services/tools/scrabble_finder_tool.dart';
import 'package:lexikit/services/tools/tool_context.dart';
import 'dart:math';

void main() {
  test('Scrabble score calculation', () {
    final tool = ScrabbleFinderTool();
    final context = ToolContext(dictionaryList: [], dictionarySet: {}, random: Random(1));
    int score(String word) => tool.scrabbleScore(word);
    expect(score('zoo'), 12);
    expect(score('cab'), 7);
    expect(score('quiz'), 22);
    expect(score('cat'), 5);
    expect(score('bat'), 5);
    expect(score('tab'), 5);
    expect(score('act'), 5);
  });
}
