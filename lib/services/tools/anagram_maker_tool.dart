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

    // If input contains spaces, treat as full anagram mode (use all letters, any word split)
    if (normalized.contains(RegExp(r'\s+'))) {
      final letters = normalized.replaceAll(RegExp(r'\s+'), '');
      if (!RegExp(r'^[a-z]+$').hasMatch(letters)) {
        return 'For sentence anagram mode, use letters and spaces only.';
      }
      final results = _findFullAnagrams(letters, context, maxResults: 80);
      if (results.isEmpty) {
        return 'No full anagrams found.';
      }
      return 'All possible anagrams using all letters (single or multi-word):\n' + results.join('\n');
    }

    if (!RegExp(r'^[a-z]+$').hasMatch(normalized)) {
      return 'Enter letters only (a-z).';
    }

    final matches = _findWordAnagrams(normalized, context);
    if (matches.isEmpty) return 'No anagrams found.';
    return matches.join('\n');
  }

  // Find all ways to split the letters into 1..N dictionary words that use all letters
  List<String> _findFullAnagrams(String letters, ToolContext context, {int maxResults = 80}) {
    final results = <String>[];
    final used = <String, List<String>>{};
    final dict = context.dictionarySet;
    final dictList = context.dictionaryList;
    final letterBag = letterCounts(letters);

    // Precompute all dictionary words that can be built from the letter bag and are <= letters.length
    // Exclude single-letter words (they're not meaningful in anagram context)
    final candidates = dictList
        .where((w) => w.length > 1 && w.length <= letters.length && canBuildWord(w, letterBag))
        .toList();

    void search(String remaining, List<String> current) {
      if (results.length >= maxResults) return;
      if (remaining.isEmpty) {
        results.add(current.join(' '));
        return;
      }
      for (final word in candidates) {
        if (word.length > remaining.length) continue;
        if (!canBuildWord(word, letterCounts(remaining))) continue;
        // Remove word's letters from remaining
        final bag = letterCounts(remaining);
        bool canUse = true;
        for (final ch in word.split('')) {
          if ((bag[ch] ?? 0) == 0) {
            canUse = false;
            break;
          }
          bag[ch] = bag[ch]! - 1;
        }
        if (!canUse) continue;
        // Build new remaining string
        final newRemaining = _subtractLetters(remaining, word);
        if (newRemaining.length == remaining.length) continue; // no progress
        current.add(word);
        search(newRemaining, current);
        current.removeLast();
      }
    }

    search(letters, <String>[]);
    // Sort by fewest words first, then alphabetically
    results.sort((a, b) {
      final aWords = a.split(' ').length;
      final bWords = b.split(' ').length;
      if (aWords != bWords) return aWords.compareTo(bWords);
      return a.compareTo(b);
    });
    return results;
  }

  String _subtractLetters(String from, String remove) {
    final fromBag = letterCounts(from);
    for (final ch in remove.split('')) {
      fromBag[ch] = fromBag[ch]! - 1;
    }
    final sb = StringBuffer();
    fromBag.forEach((ch, count) {
      for (var i = 0; i < count; i++) {
        sb.write(ch);
      }
    });
    return sb.toString();
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
