# Repository Guidelines

## Project Structure & Module Organization
- `lib/` contains app source code.
- `lib/main.dart` is the app entry point and root navigation scaffold.
- `lib/screens/` contains screen-level widgets (for example, `assets_tab_screen.dart`).
- `lib/screens/widgets/` contains reusable UI components (charts, bottom sheets, section lists, cards).
- `test/` contains widget/unit tests (`widget_test.dart` as starter).
- Platform folders: `android/`, `ios/`.

## Build, Test, and Development Commands
- `flutter pub get`: install/update dependencies from `pubspec.yaml`.
- `flutter run`: run locally on a connected device/emulator.
- `flutter analyze`: run static analysis with `flutter_lints`.
- `flutter test`: run all tests under `test/`.
- `dart format lib test`: format Dart files.
- `flutter build apk` or `flutter build ios`: produce release builds.

## Coding Style & Naming Conventions
- Follow Dart style with 2-space indentation and trailing commas for multiline widget trees.
- Use `UpperCamelCase` for classes/widgets, `lowerCamelCase` for methods/variables, and `snake_case.dart` for filenames.
- Keep UI composition in small widgets; prefer extracting repeated UI blocks into `lib/screens/widgets/`.
- Respect lints from `analysis_options.yaml` (`package:flutter_lints/flutter.yaml`).

## Testing Guidelines
- Use `flutter_test`.
- Put tests in `test/` with `_test.dart` suffix (for example, `assets_tab_screen_test.dart`).
- Prefer widget tests for UI behavior (tap, navigation, rendering states).
- Run `flutter analyze && flutter test` before opening a PR.

## Commit & Pull Request Guidelines
- This repository currently has no commit history yet; adopt a consistent convention now.
- Recommended commit style: Conventional Commits (e.g., `feat: add asset add bottom sheet`, `fix: adjust chart legend overflow`).
- PRs should include:
  - concise summary of changes,
  - linked issue/task (if available),
  - screenshots or short recordings for UI changes,
  - verification notes (`flutter analyze`, `flutter test`).

## Security & Configuration Tips
- Do not commit secrets, keys, or provisioning artifacts.
- Keep environment-specific values outside tracked source when possible.
- Validate third-party package additions for maintenance and license compatibility.

## Rules
- Always response in Korean.
