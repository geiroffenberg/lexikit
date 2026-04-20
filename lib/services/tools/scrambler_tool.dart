import '../../models/tool_type.dart';
import 'tool_context.dart';
import 'word_tool.dart';

class ScramblerTool implements WordTool {
  @override
  ToolType get type => ToolType.scrambler;

  @override
  String get title => 'Scrambler';

  @override
  String get hint => 'text e.g. lexikit';

  @override
  bool get requiresDictionary => true;

  @override
  String run(String input, ToolContext context) {
    final cleaned = input.replaceAll(RegExp(r'\s+'), '').toLowerCase();

    if (cleaned.isEmpty) {
      return 'Enter text to scramble.';
    }
    if (!RegExp(r'^[a-z]+$').hasMatch(cleaned)) {
      return 'Use letters and spaces only.';
    }
    if (cleaned.length < 2) {
      return 'Enter at least 2 letters.';
    }

    final chars = cleaned.split('');
    final options = <String>{};
    const maxOptions = 10;
    const maxAttempts = 6000;
    var attempts = 0;

    while (options.length < maxOptions && attempts < maxAttempts) {
      attempts += 1;
      final shuffled = List<String>.from(chars)..shuffle(context.random);
      final candidate = shuffled.join();

      if (candidate == cleaned) {
        continue;
      }
      if (context.dictionarySet.contains(candidate)) {
        continue;
      }
      options.add(candidate);
    }

    if (options.isEmpty) {
      return 'Could not generate non-dictionary options. Try a different word.';
    }

    final sorted = options.toList()..sort();
    return sorted.join('\n');
  }
}
