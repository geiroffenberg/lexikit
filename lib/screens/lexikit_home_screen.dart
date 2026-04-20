import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/tool_instructions.dart';
import '../models/tool_type.dart';
import '../services/word_tools_service.dart';
import '../widgets/tool_row.dart';

class LexiKitHomeScreen extends StatefulWidget {
  const LexiKitHomeScreen({super.key});

  @override
  State<LexiKitHomeScreen> createState() => _LexiKitHomeScreenState();
}

class _LexiKitHomeScreenState extends State<LexiKitHomeScreen> {
  final WordToolsService _service = WordToolsService();

  final Map<ToolType, TextEditingController> _controllers = {
    for (final type in ToolType.values) type: TextEditingController(),
  };

  final Map<ToolType, String?> _results = {
    for (final type in ToolType.values) type: null,
  };

  final Map<ToolType, bool> _loadingByTool = {
    for (final type in ToolType.values) type: false,
  };

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _initialize() async {
    await _service.loadDictionary();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _runTool(ToolType type) async {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _loadingByTool[type] = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 16));

    final input = _controllers[type]!.text.trim().toLowerCase();
    final output = await Future<String>(() => _service.runTool(type, input));

    if (!mounted) return;

    setState(() {
      _results[type] = output;
      _loadingByTool[type] = false;
    });
  }

  void _resetAll() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      for (final controller in _controllers.values) {
        controller.clear();
      }
      for (final type in ToolType.values) {
        _results[type] = null;
        _loadingByTool[type] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surfaceContainerLowest,
                colorScheme.surface,
              ],
            ),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('LexiKit', style: textTheme.headlineSmall),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _resetAll,
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                  if (_service.loadingError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _service.loadingError,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  const SizedBox(height: 10),
                  for (final type in ToolType.values)
                    if (_service.toolTitle(type) != 'Unknown Tool') ...[
                      ToolRow(
                        title: _service.toolTitle(type),
                        hintText: _service.toolHint(type),
                        controller: _controllers[type]!,
                        onGo: () => _runTool(type),
                        isLoading: _loadingByTool[type] ?? false,
                      ),
                      if (_results[type] != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 8, bottom: 14),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _ResultView(
                            resultText: _results[type]!,
                            textStyle: textTheme.bodyMedium,
                          ),
                        )
                      else if (_loadingByTool[type] == false)
                        const SizedBox(height: 14),
                    ],
                  const SizedBox(height: 6),
                  _SectionHeading(
                      title: 'Instructions',
                      subtitle: 'How every tool works in plain language.'),
                  const SizedBox(height: 8),
                  Text(
                    lexiKitInstructionsIntro,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  for (final type in ToolType.values)
                    if (lexiKitInstructions[type] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _InstructionCard(
                          instruction: lexiKitInstructions[type]!,
                        ),
                      ),
                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 10),
                  _SectionHeading(
                      title: 'Footer',
                      subtitle: 'Site information and policy text.'),
                  const SizedBox(height: 8),
                  _FooterPolicyTile(
                    title: 'About',
                    body: lexiKitAboutText,
                    initiallyExpanded: true,
                  ),
                  _FooterPolicyTile(
                    title: 'Privacy Policy',
                    body: lexiKitPrivacyText,
                  ),
                  _FooterPolicyTile(
                    title: 'Terms of Use',
                    body: lexiKitTermsText,
                  ),
                  _FooterPolicyTile(
                    title: 'Disclaimer',
                    body: lexiKitDisclaimerText,
                  ),
                  _FooterPolicyTile(
                    title: 'Contact',
                    body: lexiKitContactText,
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      lexiKitCopyrightText,
                      style: textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(subtitle, style: textTheme.bodyMedium),
      ],
    );
  }
}

class _FooterPolicyTile extends StatelessWidget {
  const _FooterPolicyTile({
    required this.title,
    required this.body,
    this.initiallyExpanded = false,
  });

  final String title;
  final String body;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14))),
          collapsedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14))),
          initiallyExpanded: initiallyExpanded,
          title: Text(
            title,
            style: textTheme.titleMedium,
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                body,
                style: textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({required this.instruction});

  final ToolInstruction instruction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            instruction.title,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            instruction.body,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {

  const _ResultView({
    required this.resultText,
    this.textStyle,
  });

  final String resultText;
  final TextStyle? textStyle;

  Widget _buildWordWithScore(String word, BuildContext context) {
    final match = RegExp(r'^(?<w>[a-z-]+)(?: \((?<s>\d+)\))?$').firstMatch(word);
    if (match == null) {
      return Text(word, style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w600,
      ));
    }
    final w = match.namedGroup('w')!;
    final s = match.namedGroup('s');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(w, style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        )),
        if (s != null) ...[
          const SizedBox(width: 4),
          Text('($s)', style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          )),
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = _extractWordList(resultText);
    if (words == null) {
      return Text(resultText, style: textStyle);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final word in words)
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: word));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('Copied "$word"')),
                );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: _buildWordWithScore(word, context),
            ),
          ),
      ],
    );
  }

  List<String>? _extractWordList(String raw) {
    final lines = raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) return null;

    // Accept lines like 'word' or 'word (12)' for Scrabble Finder
    final allWordOrScored = lines.every((line) =>
        RegExp(r'^[a-z-]+( \(\d+\))?$').hasMatch(line));
    if (!allWordOrScored) return null;
    return lines;
  }
}
