import 'dart:math';

import 'package:flutter/services.dart';

import '../models/tool_type.dart';
import 'tools/anagram_maker_tool.dart';
import 'tools/crossword_finder_tool.dart';
import 'tools/random_word_generator_tool.dart';
import 'tools/scrambler_tool.dart';
import 'tools/tool_context.dart';
import 'tools/unscrambler_tool.dart';
import 'tools/word_tool.dart';
import 'tools/word_validator_tool.dart';
import 'tools/scrabble_finder_tool.dart';

class WordToolsService {
  final Random _random = Random();
  final Map<ToolType, WordTool> _tools = {
    ToolType.scrabbleFinder: ScrabbleFinderTool(),
    ToolType.unscrambler: UnscramblerTool(),
    ToolType.scrambler: ScramblerTool(),
    ToolType.anagramMaker: AnagramMakerTool(),
    ToolType.crosswordFinder: CrosswordFinderTool(),
    ToolType.wordValidator: WordValidatorTool(),
    ToolType.randomWordGenerator: RandomWordGeneratorTool(),
    // ToolType.wordCounter: WordCounterTool(), // Blocked out
    // ToolType.syllableCounter: SyllableCounterTool(), // Blocked out
  };

  bool loadingWords = true;
  String loadingError = '';
  List<String> dictionaryList = <String>[];
  Set<String> dictionarySet = <String>{};

  Future<void> loadDictionary() async {
    try {
      final raw = await rootBundle.loadString('assets/words_alpha.txt');
      final words = raw
          .split('\n')
          .map((line) => line.trim().toLowerCase())
          .where((line) => line.isNotEmpty)
          .where((line) => RegExp(r'^[a-z-]+$').hasMatch(line))
          .toList(growable: false);

      dictionaryList = words;
      dictionarySet = words.toSet();
      loadingWords = false;
      loadingError = '';
    } catch (e) {
      loadingWords = false;
      loadingError = 'Failed to load dictionary: $e';
    }
  }

  String runTool(ToolType type, String input) {
    final tool = _tools[type];
    if (tool == null) {
      return 'Tool not available.';
    }

    if (tool.requiresDictionary && !isReady()) {
      return dictionaryNotReadyMessage();
    }

    final context = ToolContext(
      dictionaryList: dictionaryList,
      dictionarySet: dictionarySet,
      random: _random,
    );
    return tool.run(input, context);
  }

  String toolTitle(ToolType type) {
    return _tools[type]?.title ?? 'Unknown Tool';
  }

  String toolHint(ToolType type) {
    return _tools[type]?.hint ?? '';
  }

  bool isReady() => !loadingWords && loadingError.isEmpty;

  String dictionaryStatus() {
    if (loadingWords) return 'Loading...';
    return '${dictionaryList.length} words loaded';
  }

  String dictionaryNotReadyMessage() {
    if (loadingWords) return 'Dictionary is still loading...';
    if (loadingError.isNotEmpty) return loadingError;
    return 'Dictionary not ready.';
  }
}
