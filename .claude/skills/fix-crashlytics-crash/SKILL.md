---
name: fix-crashlytics-crash
description: Investigate and fix a crash reported by Firebase Crashlytics in the money_mate Flutter app — analyze the stack trace, locate the root cause in the Clean Architecture layers, apply a fix following project conventions, and verify. Use whenever the user pastes a Crashlytics issue/stack trace, mentions a crash from Crashlytics, or asks to fix/triage/resolve a crash found in monitoring.
---

# Firebase Crashlytics 크래시 해결 (money_mate)

Firebase 프로젝트: `money-mate-ae327`
콘솔: https://console.firebase.google.com/project/money-mate-ae327/crashlytics

## 0. 전제와 한계

Crashlytics는 크래시 리포트를 읽어오는 공식 API/CLI가 없다(BigQuery export도 이 프로젝트에는 설정돼 있지 않음, `firebase` CLI는 심볼 업로드용이지 조회용이 아님). 따라서 이 스킬은 **사용자가 Firebase Console에서 복사해온 크래시 정보를 입력받아** 코드 레벨 원인 분석과 수정을 수행하는 것을 전제로 한다.

## 1. 핫픽스인 경우: 작업 전에 브랜치부터 만든다

사용자가 "핫픽스"라고 명시하거나, 이미 배포된 버전에서 발생한 크래시를 급하게 고쳐 재배포해야 하는 상황이면, 크래시 분석(2절)에 들어가기 전에 아래 순서로 브랜치를 먼저 준비한다. 단순 크래시 조사/일반 수정 요청이면 이 절은 건너뛴다.

1. **작업 트리 확인** — `git status`로 커밋 안 된 변경사항이 있는지 확인한다. 있으면 stash하거나 먼저 처리할지 사용자에게 확인한다.
2. **main으로 전환 후 최신화**
   ```bash
   git checkout main
   git pull origin main
   ```
3. **패치 버전 결정** — `pubspec.yaml`의 현재 `version: X.Y.Z+N`에서 patch(`Z`)를 1 올리고 build number(`N`)도 1 올린다. (예: `1.3.0+8` → `1.3.1+9`)
4. **버전 반영** — `bump-version` 스킬(`.claude/skills/bump-version/SKILL.md`) 절차를 그대로 따라 `pubspec.yaml` 수정 → `flutter pub get` → `flutter build ios --config-only`까지 수행해 iOS 빌드 캐시까지 갱신한다.
5. **버전 커밋** — `chore: 앱 버전을 1.3.1+9로 업데이트` 형태(기존 커밋 히스토리 컨벤션과 동일)로 main 위에 커밋한다.
6. **핫픽스 브랜치 생성** — 새 versionName 그대로 `v<X.Y.Z>` 이름으로 브랜치를 만들고 전환한다 (기존 릴리즈 브랜치 `v1.2.0`, `v1.3.0`과 동일한 네이밍 컨벤션).
   ```bash
   git checkout -b v1.3.1
   ```
7. 이후 2절(원인 분석)부터 진행하고, 크래시 수정 커밋은 이 핫픽스 브랜치 위에 쌓는다.

주의: 이 저장소는 릴리즈마다 동일 이름의 **브랜치와 태그**가 함께 존재해서(`v1.2.0`, `v1.3.0`) `git log v1.3.0`처럼 이름만 쓰면 ambiguous 경고가 날 수 있다. 특정이 필요하면 `refs/heads/v1.3.1`처럼 풀네임을 쓴다.

## 2. 크래시 정보 수집

사용자가 아래 정보를 안 줬다면 먼저 요청한다 (전부 필수는 아니고, 스택 트레이스만 있어도 시작 가능):

- **예외 타입/메시지** (예: `type 'Null' is not a subtype of type 'String'`, `RangeError (index)`)
- **전체 스택 트레이스** (콘솔의 Stack trace 섹션을 펼쳐서 전체 복사 — 최상단 프레임이 잘려있으면 부정확한 분석으로 이어짐)
- **Fatal 여부** (Crashlytics의 Crashes 탭 vs Non-fatals 탭)
- **발생 버전** (예: `1.3.0 (7)`) — `pubspec.yaml`의 현재 버전과 비교해 이미 고쳐졌을 가능성 체크
- **플랫폼** (iOS/Android) — 플랫폼 채널, 네이티브 심볼 관련 이슈면 갈라짐
- **영향 사용자 수 / 발생 횟수** — 우선순위 판단용
- **Custom keys / Logs** (있다면) — `recordError`의 `information`이나 breadcrumb으로 남긴 컨텍스트

## 3. 원인 분석 절차

1. 스택 트레이스에서 `package:money_mate/...`로 시작하는 **가장 위쪽 프레임**을 찾는다 — 실제 크래시 지점.
   - Android release는 심볼 업로드가 설정돼 있으므로(`5ca2c96` 커밋, FlutterFire Crashlytics 심볼 업로드) 난독화 없이 원본 파일/라인이 그대로 보여야 정상이다. 파일명이 안 보이고 네이티브 주소만 보이면 심볼 업로드 누락을 먼저 의심한다.
2. 해당 파일을 Read로 열어서 Clean Architecture 계층(`UI → ViewModel → Repository → DataSource → Database`) 중 어디인지 확인한다.
3. **로컬 DB(Drift) 쪽이면 이미 계측돼 있을 가능성이 높다.** `lib/data/local/db_crashlytics_logger.dart`의 `logDbErrors`/`logDbStreamErrors`가 `asset_local_data_source.dart`, `ledger_record_local_data_source.dart`, `favorite_ledger_record_local_data_source.dart`, `portfolio_target_local_data_source.dart`에서 쓰이고 있고, non-fatal 리포트의 `reason` 필드가 `Local DB operation failed: <operation>` 형태로 남으므로 그 `<operation>` 문자열로 바로 해당 DataSource 메서드를 특정할 수 있다.
4. Fatal(uncaught)은 `main.dart`의 `FlutterError.onError` / `PlatformDispatcher.instance.onError`까지 올라온 것이므로, 어떤 위젯 빌드/콜백에서 던져졌는지 스택을 따라간다.
5. Dart/Flutter 흔한 크래시 패턴 체크리스트:
   - **Null 관련**: `!` 강제 언래핑, `late` 변수 미초기화 상태 접근
   - **타입 캐스팅**: `as SomeType`, `type 'X' is not a subtype of type 'Y'`
   - **인덱스/빈 컬렉션**: `RangeError`, 빈 리스트에 `.first`/`.last`/`[0]`
   - **비동기 후 UI 접근**: `dispose` 이후 `setState`, unmounted `BuildContext`의 `Navigator`/`Theme.of` 등
   - **숫자 파싱/통화 변환**: 사용자 입력 금액 `double.parse`/`int.parse` 실패
   - **Drift 마이그레이션**: 스키마 버전 안 맞음, nullable/NOT NULL 컬럼 불일치
   - **PlatformException**: 알림 권한, 플랫폼 채널 오류

## 4. 수정 원칙 (CLAUDE.md 준수)

- Clean Architecture 의존성 방향을 깨지 않는다 (ViewModel은 Repository를 통해서만 접근, DataSource 직접 참조 금지).
- 방어 코드를 추가할 때 **단순 try-catch로 삼키지 않는다.** DB 레이어 수정이면 기존 `logDbErrors`/`logDbStreamErrors` 패턴을 그대로 재사용해서 non-fatal 계측을 유지한다. 다른 레이어에서 새로 캐치가 필요하면 `FirebaseCrashlytics.instance.recordError(..., fatal: false)`로 남기고 원인이 소실되지 않게 한다.
- 근본 원인을 고치는 것이 우선이다. "크래시 안 나게 try-catch로 감싸고 non-fatal 로그만 남긴다"는 회피책은 재발 방지가 아니므로, 가능하면 애초에 null/범위/타입 오류가 발생하지 않도록 로직을 고친다.
- 색상 하드코딩 금지, UI 문자열 l10n 처리(`app_ko.arb`/`app_en.arb` 동시 추가) 등 CLAUDE.md의 기존 규칙을 그대로 따른다.

## 5. 검증

```bash
flutter analyze
flutter test
```

크래시를 재현하는 유닛/위젯 테스트가 없다면, 특히 파싱·계산 로직처럼 회귀가 쉬운 부분은 재발 방지용 테스트를 추가하는 걸 고려한다.

## 6. 커밋 & 콘솔 처리

- 사용자가 명시적으로 커밋을 요청한 경우에만 `fix: <크래시 원인> 수정` 형태(한글, Conventional Commits)로 커밋한다.
- 1절에서 핫픽스 브랜치(`v1.3.1` 등)를 만든 경우, 이 브랜치가 PR의 base가 아니라 **head**다 — main을 기준으로 diff/PR을 만든다.
- 배포 후 Crashlytics 콘솔에서 해당 issue를 Closed 처리하는 것은 콘솔에서 수동으로 하도록 안내만 한다(자동화 API 없음).

## 7. 여러 크래시가 한 번에 들어온 경우 우선순위

1. Fatal > Non-fatal
2. 영향 사용자 수(또는 발생 횟수) 많은 순
3. 최신 배포 버전에서도 재발하는 것 우선 (구버전에서만 발생하고 이후 커밋으로 이미 고쳐졌을 수 있으니 diff부터 확인)
