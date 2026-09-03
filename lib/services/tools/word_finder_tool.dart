import '../../models/tool_type.dart';
import 'tool_context.dart';
import 'word_tool.dart';
import 'word_tool_utils.dart';

/// Merged replacement for Scrabble Finder + Unscrambler.
///
/// Finds every dictionary word (length >= 2 by default) that can be built from
/// the given letters, then sorts by Scrabble points (score desc, length desc,
/// then alphabetically) so the strongest / longest plays surface first.
///
/// Optional inline filters (space-separated) narrow results the way real
/// solver sites do. The tool is game-neutral on the core finder (it just lists
/// every buildable dictionary word) but sorts by Scrabble score by default.
///
/// Examples:
///   `planet`              -> every word of length 2+ from P,L,A,N,E,T
///   `planet exact:5`      -> only length-5 words (old Unscrambler behavior)
///   `planet min:4`        -> only words with 4+ letters
///   `planet starts:pl`    -> only words beginning with "pl"
///   `planet ends:et`      -> only words ending with "et"
///   `planet has:an`       -> only words whose text contains "an"
///   `c?t`  (wildcards)    -> up to 2 blanks via '?', '*', or '_'
class WordFinderTool implements WordTool {
  @override
  ToolType get type => ToolType.wordFinder;

  @override
  String get title => 'Word Finder';

  @override
  String get hint => 'letters [?/*/_] + exact:N min:N starts:.. ends:..';

  @override
  bool get requiresDictionary => true;

  static const int _maxResults = 220;

  @override
  String run(String input, ToolContext context) {
    final parsed = _parseInput(input.trim());
    if (parsed.error != null) return parsed.error!;

    final bag = letterCounts(parsed.letters);
    final wildcardCount = parsed.wildcardCount;

    final matches = <String>[];
    for (final word in context.dictionaryList) {
      if (word.length < 2) continue;
      if (word.length < parsed.minLength) continue;
      if (word.length > parsed.maxLength) continue;
      if (!word.startsWith(parsed.startsWith)) continue;
      if (!word.endsWith(parsed.endsWith)) continue;
      if (parsed.requiredSubstring.isNotEmpty &&
          !word.contains(parsed.requiredSubstring)) {
        continue;
      }
      if (!_canBuild(word, bag, wildcardCount)) continue;
      matches.add(word);
    }

    if (matches.isEmpty) return 'No words found.';

    final unique = <String>{};
    final distinct = matches.where(unique.add).toList();
    distinct.sort((a, b) {
      final pa = scrabbleScore(a);
      final pb = scrabbleScore(b);
      if (pa != pb) {
        return pb.compareTo(pa);
      }
      if (a.length != b.length) {
        return b.length.compareTo(a.length);
      }
      return a.compareTo(b);
    });

    return distinct
        .take(_maxResults)
        .map((w) => '$w (${scrabbleScore(w)})')
        .join('\n');
  }

  bool _canBuild(String word, Map<String, int> bag, int wildcardCount) {
    final needed = <String, int>{};
    for (final ch in word.split('')) {
      needed[ch] = (needed[ch] ?? 0) + 1;
    }
    int wildsLeft = wildcardCount;
    for (final entry in needed.entries) {
      final have = bag[entry.key] ?? 0;
      if (have < entry.value) {
        wildsLeft -= entry.value - have;
        if (wildsLeft < 0) return false;
      }
    }
    return true;
  }

  /// Standard English Scrabble letter values.
  int scrabbleScore(String word) {
    const scores = {
      'a': 1,
      'e': 1,
      'i': 1,
      'o': 1,
      'u': 1,
      'l': 1,
      'n': 1,
      's': 1,
      't': 1,
      'r': 1,
      'd': 2,
      'g': 2,
      'b': 3,
      'c': 3,
      'm': 3,
      'p': 3,
      'f': 4,
      'h': 4,
      'v': 4,
      'w': 4,
      'y': 4,
      'k': 5,
      'j': 8,
      'x': 8,
      'q': 10,
      'z': 10,
    };
    var total = 0;
    for (final ch in word.split('')) {
      total += scores[ch] ?? 0;
    }
    return total;
  }

  _Parsed _parseInput(String input) {
    // Recognise filter tokens: exact:N, min:N, max:N, starts:X, ends:X, has:X
    final tokenRe = RegExp(r'\b(exact|min|max|starts|ends|has):([a-z0-9]+)\b');

    // Letters are what remains after removing recognised tokens and whitespace.
    final lettersWithWildcards = input.replaceAll(tokenRe, ' ');

    // Wildcards are explicit '?', '*', or '_'. Plain spaces are ignored, so
    // filter tokens can be separated naturally without tripping wildcard count.
    var wildcardCount = 0;
    final lettersBuf = StringBuffer();
    for (final ch in lettersWithWildcards.split('')) {
      if (RegExp(r'[a-z]').hasMatch(ch)) {
        lettersBuf.write(ch);
      } else if (ch == '?' || ch == '*' || ch == '_') {
        wildcardCount++;
      } else if (ch == ' ') {
        // separator between letters and filters; ignored
      }
      // any other char -> invalid
      else {
        return _Parsed.error('Enter letters (a-z) with wildcards (?, *, _).');
      }
    }
    final letters = lettersBuf.toString();
    if (letters.isEmpty) {
      return _Parsed.error('Enter letters first, e.g. "planet".');
    }
    if (wildcardCount > 2) {
      return _Parsed.error('Maximum 2 wildcards allowed.');
    }

    var minLength = 2;
    var maxLength = 30;
    var startsWith = '';
    var endsWith = '';
    var requiredSubstring = '';

    for (final m in tokenRe.allMatches(input)) {
      final key = m.group(1)!;
      final value = m.group(2)!;
      switch (key) {
        case 'exact':
        case 'length':
          final n = int.tryParse(value);
          if (n == null || n < 1) {
            return _Parsed.error('exact:N expects a positive number.');
          }
          minLength = n;
          maxLength = n;
          break;
        case 'min':
          final n = int.tryParse(value);
          if (n == null || n < 1) {
            return _Parsed.error('min:N expects a positive number.');
          }
          minLength = n;
          break;
        case 'max':
          final n = int.tryParse(value);
          if (n == null || n < 1) {
            return _Parsed.error('max:N expects a positive number.');
          }
          maxLength = n;
          break;
        case 'starts':
          startsWith = value;
          break;
        case 'ends':
          endsWith = value;
          break;
        case 'has':
          requiredSubstring = value;
          break;
      }
    }

    if (minLength > maxLength) {
      // exact already handled; filters that contradict (min > max) resolve to max.
      return _Parsed.error('Filter range is empty (min is larger than max).');
    }

    return _Parsed.ok(
      letters: letters,
      wildcardCount: wildcardCount,
      minLength: minLength,
      maxLength: maxLength,
      startsWith: startsWith,
      endsWith: endsWith,
      requiredSubstring: requiredSubstring,
    );
  }
}

class _Parsed {
  _Parsed.ok({
    required this.letters,
    required this.wildcardCount,
    required this.minLength,
    required this.maxLength,
    required this.startsWith,
    required this.endsWith,
    required this.requiredSubstring,
  }) : error = null;

  _Parsed.error(this.error)
      : letters = '',
        wildcardCount = 0,
        minLength = 2,
        maxLength = 30,
        startsWith = '',
        endsWith = '',
        requiredSubstring = '';

  final String? error;
  final String letters;
  final int wildcardCount;
  final int minLength;
  final int maxLength;
  final String startsWith;
  final String endsWith;
  final String requiredSubstring;
}
