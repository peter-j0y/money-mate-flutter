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

### Clean Architecture 원칙

**계층 구조 및 의존성 방향:**
```
UI (Screen/Widget) → ViewModel → Repository → DataSource → Database
```

- **ViewModel**: Repository를 통해서만 데이터 접근 (DataSource 직접 참조 금지)
- **Repository**: 추상 인터페이스 + 구현체 분리 (`*_repository.dart` + `*_repository_impl.dart`)
- **DataSource**: 실제 데이터 소스(DB, API) 접근 담당

**파일 구조 예시:**
```
lib/data/
├── local/
│   └── asset_local_data_source.dart      # DB 접근
├── repositories/
│   ├── asset_repository.dart             # 추상 인터페이스
│   └── asset_repository_impl.dart        # 구현체
└── model/entities/
    └── asset_entry.dart                  # 도메인 모델
```

**새 기능 추가 시:**
1. Entity 정의 (`data/model/entities/`)
2. DataSource 구현 (`data/local/` 또는 `data/remote/`)
3. Repository 인터페이스 + 구현체 생성 (`data/repositories/`)
4. ViewModel에서 Repository 주입받아 사용

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

### Localization Guidelines

**UI에 노출되는 모든 문자열은 하드코딩하지 않고 다국어 처리합니다.**

- **양쪽 arb 파일 동시 추가**: 새 문자열을 추가할 때는 `lib/l10n/app_ko.arb`와 `lib/l10n/app_en.arb`에 동일한 키로 반드시 함께 추가
- **하드코딩 금지**: 위젯 내 문자열 리터럴 직접 작성 금지. 반드시 `AppLocalizations.of(context)!.xxx` (또는 프로젝트에서 사용하는 접근자)를 통해 참조
- **키 작성 후 코드 생성**: arb 파일 수정 후 `flutter gen-l10n` 또는 `flutter pub get`으로 생성 코드 갱신 확인

### Naming Conventions

- Classes: `UpperCamelCase`
- Files: `snake_case.dart`
- Screens: `*_screen.dart`
- Tests: `*_test.dart` in `test/`

## Commit Guidelines

- Use Conventional Commits in Korean: `feat: 자산 추가 화면 구현`, `fix: 차트 오버플로우 수정`
- Run `flutter analyze && flutter test` before committing