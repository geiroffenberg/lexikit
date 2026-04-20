import '../../models/tool_type.dart';
import 'tool_context.dart';
import 'word_tool.dart';
import 'word_tool_utils.dart';

class AnagramMakerTool implements WordTool {
  @override
  ToolType get type => ToolType.anagramMaker;

  @override
  String get title => 'Anagram Maker';

  @override
  String get hint => 'letters e.g. listen';

  @override
  bool get requiresDictionary => true;

  @override
  String run(String input, ToolContext context) {
    final normalized = input.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Enter letters only (a-z).';
    }

    final hasSpaces = normalized.contains(RegExp(r'\s+'));
    if (hasSpaces) {
      return _runSentenceMode(normalized, context);
    }

    if (!RegExp(r'^[a-z]+$').hasMatch(normalized)) {
      return 'Enter letters only (a-z).';
    }

    final matches = _findWordAnagrams(normalized, context);
    if (matches.isEmpty) return 'No anagrams found.';
    return matches.join('\n');
  }

  String _runSentenceMode(String sentence, ToolContext context) {
    if (!RegExp(r'^[a-z\s]+$').hasMatch(sentence)) {
      return 'For sentence mode, use letters and spaces only.';
    }

    final words = sentence.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) {
      return 'For sentence mode, use letters and spaces only.';
    }

    final optionsByWord = <List<String>>[];
    for (final word in words) {
      final options = _findWordAnagrams(word, context);
      if (options.isEmpty) {
        return 'This is a sentence. Each word will be an anagram.\nNo sentences possible.';
      }
      optionsByWord.add(options);
    }

    final sentences = _buildSentenceOptions(optionsByWord, limit: 80);
    if (sentences.isEmpty) {
      return 'This is a sentence. Each word will be an anagram.\nNo sentences possible.';
    }

    final lines = <String>[
      'This is a sentence. Each word will be an anagram.',
      ...sentences,
    ];
    return lines.join('\n');
  }

  List<String> _findWordAnagrams(String word, ToolContext context) {
    final target = sortedLetters(word);
    final matches = context.dictionaryList
        .where((candidate) => candidate.length == word.length)
        .where((candidate) => sortedLetters(candidate) == target)
        .where((candidate) => candidate != word)
        .toSet()
        .toList()
      ..sort();
    return matches;
  }

  List<String> _buildSentenceOptions(List<List<String>> optionsByWord, {required int limit}) {
    final results = <String>[];

    void build(int index, List<String> current) {
      if (results.length >= limit) return;
      if (index == optionsByWord.length) {
        results.add(current.join(' '));
        return;
      }

      for (final option in optionsByWord[index]) {
        if (results.length >= limit) break;
        current.add(option);
        build(index + 1, current);
        current.removeLast();
      }
    }

    build(0, <String>[]);
    return results;
  }
}
