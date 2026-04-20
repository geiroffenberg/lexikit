import 'tool_type.dart';

class ToolInstruction {
  const ToolInstruction({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

const String lexiKitInstructionsIntro =
    'LexiKit works fully offline using the built-in dictionary file. Enter your input in any tool row, tap Go, and scroll to the result box below that row. The notes below explain exactly what each tool does.';

const Map<ToolType, ToolInstruction> lexiKitInstructions = {
  ToolType.unscrambler: ToolInstruction(
    title: 'Unscrambler',
    body:
        'Enter a single group of letters with no spaces. LexiKit looks for exact-length dictionary words that can be made from those letters. Results are shown as separate word pills, and you can tap any pill to copy it.',
  ),
  ToolType.scrambler: ToolInstruction(
    title: 'Scrambler',
    body:
        'Enter a word or phrase. Spaces are ignored. LexiKit creates up to 10 shuffled versions that are not real dictionary words, so the results are useful for games, naming ideas, or puzzles.',
  ),
  ToolType.anagramMaker: ToolInstruction(
    title: 'Anagram Maker',
    body:
        'For a single word, LexiKit shows all dictionary anagrams of that word. For a sentence, each word is treated separately and the result becomes a new sentence made from word-by-word anagrams. If one word has no anagram, LexiKit will say that no sentence is possible.',
  ),
  ToolType.crosswordFinder: ToolInstruction(
    title: 'Crossword Finder',
    body:
        'Enter a pattern using letters and wildcards. The symbols *, _, and ? all work as single-character wildcards. A hyphen stays as a real hyphen. LexiKit returns every dictionary word that matches the pattern.',
  ),
  ToolType.wordValidator: ToolInstruction(
    title: 'Word Validator',
    body:
        'Enter one word. LexiKit checks whether that exact word exists in the offline dictionary and clearly confirms or denies it.',
  ),
  ToolType.randomWordGenerator: ToolInstruction(
    title: 'Random Word Generator',
    body:
        'Enter a number for word length. LexiKit returns up to 10 random dictionary words of that length and tries to give you a varied set with as many different letters as possible.',
  ),
  ToolType.wordCounter: ToolInstruction(
    title: 'Word Counter',
    body:
        'Enter any sentence, paragraph, or block of text. LexiKit counts the words and shows the total instantly.',
  ),
  ToolType.syllableCounter: ToolInstruction(
    title: 'Syllable Counter',
    body:
        'Enter any sentence, paragraph, or block of text. LexiKit estimates the total number of syllables in the text. This is a quick offline estimate, so unusual words may not always be perfect.',
  ),
};