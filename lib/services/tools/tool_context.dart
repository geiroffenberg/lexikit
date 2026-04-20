import 'dart:math';

class ToolContext {
  const ToolContext({
    required this.dictionaryList,
    required this.dictionarySet,
    required this.random,
  });

  final List<String> dictionaryList;
  final Set<String> dictionarySet;
  final Random random;
}
