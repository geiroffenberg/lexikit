# LexiKit

LexiKit is an offline-first word tools app built with Flutter.

Live website:
https://geiroffenberg.github.io/lexikit/

## What It Includes

LexiKit currently provides these tools:

1. Unscrambler
2. Scrambler
3. Anagram Maker
4. Crossword Finder
5. Word Validator
6. Random Word Generator
7. Word Counter
8. Syllable Counter

All core functionality runs using the local dictionary asset in [assets/words_alpha.txt](assets/words_alpha.txt).

## About

LexiKit is designed to be simple, fast, and practical for puzzle solving and quick writing support. The same content and tool behavior can be used in both the mobile app and web version.

## Privacy

LexiKit does not require account login and does not need a backend for core tools. Inputs are processed locally by the app using the bundled dictionary data.

If analytics, ads, or external services are added in the future, update the privacy section with exact details.

## Run Locally

From the project root:

```bash
flutter pub get
flutter run
```

Run in browser:

```bash
flutter run -d chrome
```

## Tests

Run focused tool tests:

```bash
flutter test test/random_word_generator_tool_test.dart test/word_counter_tool_test.dart test/syllable_counter_tool_test.dart test/crossword_finder_tool_test.dart test/anagram_maker_tool_test.dart test/scrambler_tool_test.dart test/unscrambler_tool_test.dart test/word_validator_tool_test.dart
```

## GitHub Pages Deployment

This repository uses the workflow in [.github/workflows/deploy-pages.yml](.github/workflows/deploy-pages.yml) to deploy automatically on pushes to `main`.

### One-time setup

1. Open your repository on GitHub.
2. Go to Settings > Pages.
3. Set Source to GitHub Actions.

### Normal publish flow

1. Make your changes.
2. Commit and push to `main`.
3. Wait for the GitHub Action to complete.
4. Refresh the live site URL.

## Publish Checklist

Use this quick checklist before pushing site updates:

1. Run local tests.
2. Check text and instruction content for clarity.
3. Verify app works on both mobile layout and wide web layout.
4. Commit with a clear message.
5. Push to `main`.
6. Confirm green action run in GitHub Actions.
7. Verify the live page renders correctly.

## Project Structure (Core)

1. App setup: [lib/app/lexikit_app.dart](lib/app/lexikit_app.dart)
2. Home UI: [lib/screens/lexikit_home_screen.dart](lib/screens/lexikit_home_screen.dart)
3. Tool engine: [lib/services/word_tools_service.dart](lib/services/word_tools_service.dart)
4. Tool implementations: [lib/services/tools](lib/services/tools)
5. Shared tool instructions and reusable copy: [lib/models/tool_instructions.dart](lib/models/tool_instructions.dart)
