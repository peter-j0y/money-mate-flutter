# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Language & Communication

**Always respond in Korean.** Add a one-point lesson related to the code you modified at the end of each response.

## Build & Development Commands

```bash
flutter pub get                    # Install dependencies
flutter run                        # Run on device/emulator
flutter analyze                    # Static analysis
dart format lib test               # Format code
flutter test                       # Run all tests
dart run build_runner build        # Generate Drift database code
```

## Architecture Overview

Flutter personal finance app (Dart 3.7.2+) with Clean Architecture:

```
lib/
├── main.dart                      # Entry point with tab navigation
├── data/
│   ├── local/                     # Drift/SQLite database layer
│   ├── model/entities/            # Domain models (LedgerEntry, AssetEntry)
│   └── repositories/              # Repository pattern (abstract + impl)
└── ui/
    ├── core/
    │   ├── design_system/         # Color tokens, themes
    │   └── [shared widgets]
    ├── ledger/                    # Feature: income/expense tracking
    │   ├── view_models/           # ChangeNotifier state management
    │   └── widgets/
    └── asset/                     # Feature: asset management
        ├── view_models/
        └── screen/
```

### Key Patterns

- **State Management**: ChangeNotifier + Provider (no external library)
- **Database**: Drift ORM with SQLite. Run `dart run build_runner build` after modifying tables.
- **Design System**: Use `context.appColors.*` for theme-aware colors (defined in `app_colors.dart`, `app_semantic_colors.dart`)
- **Localization**: Korean primary, English secondary

### Color Usage Guidelines

**모든 색상은 라이트/다크 모드 대응이 되어야 합니다.**

- **시맨틱 색상 우선**: `context.appColors.primary`, `context.appColors.danger`, `context.appColors.success` 등 사용
- **하드코딩 금지**: `Color(0xFF...)` 직접 사용 금지. 반드시 `AppColors` 토큰 사용
- **배경색 동적 생성**: 다크 모드에서 밝은 배경색이 필요할 경우 `color.withValues(alpha: isDark ? 0.2 : 0.1)` 패턴 사용
- **테마 체크**: `final isDark = Theme.of(context).brightness == Brightness.dark;`

### Naming Conventions

- Classes: `UpperCamelCase`
- Files: `snake_case.dart`
- Screens: `*_screen.dart`
- Tests: `*_test.dart` in `test/`

## Commit Guidelines

- Use Conventional Commits in Korean: `feat: 자산 추가 화면 구현`, `fix: 차트 오버플로우 수정`
- Run `flutter analyze && flutter test` before committing