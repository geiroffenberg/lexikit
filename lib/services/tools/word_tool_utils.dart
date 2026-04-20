import 'dart:math';

Map<String, int> letterCounts(String text) {
  final counts = <String, int>{};
  for (final ch in text.split('')) {
    counts[ch] = (counts[ch] ?? 0) + 1;
  }
  return counts;
}

bool canBuildWord(String word, Map<String, int> bag) {
  final needed = <String, int>{};
  for (final ch in word.split('')) {
    needed[ch] = (needed[ch] ?? 0) + 1;
    if ((needed[ch] ?? 0) > (bag[ch] ?? 0)) {
      return false;
    }
  }
  return true;
}

String sortedLetters(String word) {
  final letters = word.split('')..sort();
  return letters.join();
}

int estimateSyllables(String word) {
  final clean = word.replaceAll(RegExp(r'[^a-z]'), '');
  if (clean.isEmpty) return 0;
  if (clean.length <= 3) return 1;

  final vowels = RegExp(r'[aeiouy]+');
  var count = vowels.allMatches(clean).length;

  if (clean.endsWith('e') && !clean.endsWith('le') && count > 1) {
    count -= 1;
  }
  if (clean.endsWith('es') && clean.length > 3 && count > 1) {
    count -= 1;
  }

  return max(1, count);
}
