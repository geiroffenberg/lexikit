import 'package:flutter/material.dart';

class ToolRow extends StatelessWidget {
  const ToolRow({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    required this.onGo,
    this.isLoading = false,
  });

  final String title;
  final String hintText;
  final TextEditingController controller;
  final VoidCallback onGo;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 165,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onGo(),
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: isLoading ? null : onGo,
          child: isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Go'),
        ),
      ],
    );
  }
}
