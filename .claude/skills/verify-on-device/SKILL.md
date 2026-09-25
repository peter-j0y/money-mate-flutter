---
name: verify-on-device
description: Verify recent code changes on iOS and Android by building a release build, installing it on a real device (or emulator/simulator when no device is connected), tailing crash logs, and walking through a hands-on regression checklist as if a real user were using the app. Use whenever the user asks to verify/test/QA a change on a device, emulator, or simulator, asks "실기기에서 검증해줘/테스트해줘" or "에뮬레이터로 확인해줘", or wants to confirm something works before release.
---

# 실기기 검증 (money_mate)

`flutter analyze`/`flutter test`가 통과해도 실기기에서 크래시가 난 전례가 있다(직전 커밋 `7f7fa98`: `AndroidInitializationSettings('ic_stat_reminder')`가 release 빌드의 R8 리소스 슈링커에 의해 제거되어 알림 등록 시 `PlatformException(invalid_icon)`으로 크래시). **Debug 빌드나 시뮬레이터만으로는 이런 release 전용 문제(R8/ProGuard 리소스 슈링킹, 코드 축소, 난독화, 서명, 알림/권한 관련 네이티브 동작)를 못 잡는다.** 이 스킬은 반드시 **release 빌드를 실제 기기에 설치**해서 검증한다.

이 저장소에는 `integration_test`나 Appium/Maestro 같은 UI 자동화가 없다. 그래서 이 스킬의 역할 분담은 다음과 같다:
- **Claude**: 변경사항 파악 → release 빌드 → 실기기 설치 → 크래시/에러 로그 실시간 tail → 기능별 체크리스트 제공 → 발견된 문제 코드 확인 및 수정
- **사용자(peter)**: 기기를 손에 들고 체크리스트를 따라 실제로 탭/입력/스와이프하며 사용

## 0. 시작 전 확인

1. `git status`/`git diff`로 이번에 검증할 변경 범위를 파악한다. 여러 커밋이 쌓여있다면 사용자에게 검증 범위(이번 브랜치 전체 vs 최근 변경분)를 확인한다.
2. 정적 검증을 먼저 통과시킨다. 여기서 걸러지는 문제까지 실기기에서 찾을 필요는 없다.
   ```bash
   flutter analyze
   flutter test
   ```
3. 연결된 기기를 확인하고, 검증할 플랫폼을 정한다(둘 다가 기본이지만 한쪽만 연결되어 있으면 그쪽만 먼저 진행하고 나머지는 안내).
   ```bash
   flutter devices
   xcrun devicectl list devices      # iOS 실기기 UUID
   adb devices                        # Android 실기기
   ```
   **실기기가 없거나 연결이 안 되어 있으면 에뮬레이터/시뮬레이터로 대체한다.** Android는 `adb` 기반이라 실기기와 명령어가 동일하고(1절 그대로 사용), iOS는 `devicectl` 대신 `simctl`을 써야 한다(1-1절). 단, 완전히 동등하진 않다 — 아래 "에뮬레이터/시뮬레이터 사용 시 한계" 절을 먼저 사용자에게 알려주고 진행한다.
4. **기존 테스트 데이터가 있는 기기에서 삭제/재설치/초기화를 동반한 시나리오(신규 설치 온보딩 등)를 테스트할 계획이면, 먼저 `backup-restore-local-data` 스킬로 백업한다.** 단순 재설치 없는 release 빌드 덮어쓰기 설치는 기존 로컬 DB를 보존하므로 백업이 필수는 아니다.

## 1. iOS 실기기 검증

```bash
DEVICE_ID="<devicectl list devices 에서 확인한 UUID>"

# release 빌드 (자동 서명, 팀 62SBNR6RH9)
flutter build ios --release

# 실기기 설치
xcrun devicectl device install app --device "$DEVICE_ID" build/ios/iphoneos/Runner.app

# 콘솔에 붙인 채로 포그라운드 실행 (크래시/로그 실시간 관찰)
xcrun devicectl device process launch --device "$DEVICE_ID" --console com.peter.moneyMate
```
- `--console`로 실행하면 크래시 시 스택이 터미널에 바로 찍힌다. 이 창을 띄워둔 채로 사용자가 기기를 조작하게 한다.
- 더 상세한 크래시 리포트가 필요하면 Xcode → Window → Devices and Simulators → 기기 선택 → **View Device Logs**에서 확인 가능(GUI 대안).
- 기기가 개발자 계정에 등록되어 있지 않으면 설치가 실패한다 — 실패 메시지에 provisioning 관련 오류가 보이면 Xcode에서 해당 기기가 등록돼 있는지 먼저 확인하도록 안내한다.

### 1-1. (대안) 실기기가 없을 때: iOS 시뮬레이터

```bash
xcrun simctl list devices available   # 사용 가능한 시뮬레이터와 UDID 확인
UDID="<위에서 확인한 UDID>"
open -a Simulator --args -CurrentDeviceUDID "$UDID"

# 시뮬레이터용 release 빌드 (실기기용과 아키텍처/서명 조건이 다름)
flutter build ios --release --simulator

xcrun simctl install "$UDID" build/ios/iphonesimulator/Runner.app

# 콘솔에 붙인 채로 실행 (표준출력/에러 실시간 관찰)
xcrun simctl launch --console "$UDID" com.peter.moneyMate
```
- 크래시 리포트가 콘솔에 안 보이면 `~/Library/Logs/DiagnosticReports/`에서 `Runner_*.ips` 파일을 확인하거나, `xcrun simctl spawn "$UDID" log stream --level debug --predicate 'process == "Runner"'`로 실시간 로그를 딴 터미널에서 띄워둔다.
- 시뮬레이터는 코드 서명이 걸리지 않고 실기기와 CPU 아키텍처도 다르므로(x86_64/arm64 시뮬레이터 슬라이스), 서명·provisioning 관련 문제나 일부 네이티브 동작은 여기서 재현되지 않는다 — 아래 "한계" 절 참고.

## 2. Android 실기기 검증

```bash
# release apk 빌드 (minifyEnabled/shrinkResources 적용된 실제 배포용 빌드)
flutter build apk --release

# 설치 (기존 데이터 유지하며 덮어쓰기)
adb install -r build/app/outputs/flutter-apk/app-release.apk

# 앱 실행
adb shell monkey -p com.peter.money_mate -c android.intent.category.LAUNCHER 1

# 크래시/에러 로그 실시간 관찰 (다른 터미널에서, 사용자가 조작하는 동안 계속 띄워둔다)
adb logcat -c   # 이전 로그 비우고 시작
adb logcat | grep -iE "FATAL EXCEPTION|AndroidRuntime|money_mate|flutter"
```
- `flutter build apk --release`는 `minifyEnabled`/`shrinkResources`가 걸린 실제 배포 빌드와 동일한 조건이다. **새 네이티브 리소스(알림 아이콘, drawable, 문자열 리소스 문자열 참조 등)를 추가/변경했다면 이 release 빌드 검증을 절대 생략하지 않는다** — `android/app/src/main/res/raw/keep.xml`에 없는 신규 리소스가 문자열로만 참조되면 동일한 방식으로 제거될 수 있다.
- `adb logcat`에서 아무것도 안 잡히고 앱이 그냥 튕기면(ANR 없이 조용히 종료) `adb logcat -b crash`로 크래시 버퍼를 따로 확인한다.

### 2-1. (대안) 실기기가 없을 때: Android 에뮬레이터

별도 절차가 필요 없다 — 에뮬레이터도 `adb devices`에 `emulator-5554`처럼 잡히고, `flutter build apk --release`/`adb install`/`adb logcat` 전부 위 1절 명령을 그대로 쓰면 된다. R8/ProGuard 리소스 슈링킹 같은 release 빌드 특성은 물리 기기 여부와 무관하게 빌드 단계에서 결정되므로 에뮬레이터에서도 동일하게 재현된다. 에뮬레이터가 안 켜져 있으면:
```bash
emulator -list-avds
emulator -avd <avd이름> &
```

## 3. 실사용자 시나리오 체크리스트

아래를 iOS/Android 각각에서 반복한다. 이번 변경사항과 **직접 관련된 항목은 반드시**, 나머지는 회귀 여부 확인 차원에서 훑는다.

### 최초 진입 / 전역
- [ ] 앱 최초 실행 시 크래시 없이 첫 화면까지 도달
- [ ] 알림 권한 다이얼로그 정상 노출 및 허용/거부 각각 정상 동작
- [ ] 기기 언어를 한국어/영어로 바꿔가며 재실행 → 문자열 깨짐/누락 없음 (`app_ko.arb`/`app_en.arb` 누락 키 확인)
- [ ] 다크모드 ↔ 라이트모드 전환 시 모든 화면에서 색 대비/하드코딩 색 없이 정상 렌더링
- [ ] 앱을 백그라운드로 보냈다가 복귀 시 상태 유지, 크래시 없음
- [ ] 비행기 모드(오프라인)에서도 정상 동작 — 로컬 DB만 쓰므로 네트워크 없이도 모든 핵심 기능이 되어야 함

### 가계부(Ledger) 탭
- [ ] 수입/지출 기록 추가 (카테고리 선택, 금액/날짜 입력, 지출인 경우 결제수단 선택, 메모)
- [ ] 즐겨찾기 기록 추가 후 즐겨찾기로 빠르게 기록 추가
- [ ] 캘린더 뷰 ↔ 리스트 뷰 토글, 월 이동(이전/다음)
- [ ] 기록 상세 진입 → 수정 → 삭제 (삭제 후 월별 요약/캘린더에 즉시 반영되는지)
- [ ] 금액에 큰 수/소수점/음수 등 경계값 입력 시 크래시 없이 정상 처리 또는 적절한 검증 메시지

### 자산(Asset) 탭
- [ ] 자산 추가 (카테고리별)
- [ ] 자산 상세 진입, 수정/삭제
- [ ] 포트폴리오 비중 차트가 실제 자산 구성과 일치하게 표시
- [ ] 목표 비중 설정 후 저장, 재진입 시 유지되는지

### 더보기(More) 탭
- [ ] 주 통화 변경 → 가계부/자산 화면의 금액 표시가 즉시 반영
- [ ] 리마인더 알림 요일/시간 설정 → 실제로 해당 시간에 알림이 오는지(가능하면 몇 분 뒤로 설정해 실기기에서 직접 수신 확인 — 이번에 고친 `ic_stat_reminder` 크래시가 release 빌드에서 재발하지 않는지 이 경로로 반드시 확인)
- [ ] 법적 링크(약관/개인정보처리방침 등) 외부 브라우저로 정상 이동

### 이번 변경사항 특화 체크
- [ ] 이번 diff에서 건드린 화면/로직을 직접 골라 정상/경계 케이스를 몇 가지 더 시도한다 (0단계에서 파악한 변경 범위 기준)

## 4. 에뮬레이터/시뮬레이터 사용 시 한계

실기기가 없어서 에뮬레이터/시뮬레이터로 진행했다면, 아래 항목은 **검증됐다고 보지 말고** 가능하면 나중에 실기기로 한 번은 재확인하도록 사용자에게 알린다.

- **코드 서명/provisioning 관련 문제**: iOS 시뮬레이터는 서명이 걸리지 않으므로 실기기 설치·서명 실패는 여기서 절대 안 잡힌다.
- **release 빌드 최적화의 플랫폼별 차이**: Android는 실기기든 에뮬레이터든 같은 APK를 설치하는 것이라 거의 동일하지만, iOS 시뮬레이터 release 빌드는 실기기(arm64)와 다른 아키텍처 슬라이스로 빌드되어 완전히 같은 바이너리가 아니다.
- **알림/권한의 실제 동작**: 로컬 알림 자체는 시뮬레이터/에뮬레이터에서도 대체로 뜨지만, 실제 잠금화면·백그라운드 상태에서 지정 시각에 정확히 오는지, 진동/배지 등은 실기기에서 확인하는 게 더 확실하다.
- **성능/메모리 체감**: 에뮬레이터는 대개 개발 머신 사양을 그대로 쓰므로 저사양 실기기에서만 드러나는 렌더링 지연, 큰 리스트 스크롤 버벅임 등은 재현되지 않는다.
- **배터리/저장공간 부족, 실제 네트워크 전환(와이파이↔셀룰러)** 같은 실환경 변수도 에뮬레이터에선 흉내만 낼 수 있다.

이번 변경이 위 항목과 관련 없는 순수 UI/로직 변경이라면 에뮬레이터 검증만으로 충분한 경우가 많다. 알림, 네이티브 리소스, 권한, 서명처럼 이번에 실제로 문제가 났던 영역을 건드린 변경이라면 실기기 재검증을 권장한다.

## 5. 문제 발견 시

1. 재현 절차(정확한 탭 순서, 입력값)와 로그(iOS `--console` 출력 또는 Android `adb logcat` 스택)를 기록한다.
2. Crashlytics에 이미 잡히는 유형의 크래시면 `fix-crashlytics-crash` 스킬 절차(원인 분석 → Clean Architecture 계층 확인 → 수정)를 그대로 따른다.
3. 수정 후 `flutter analyze && flutter test`를 다시 통과시키고, **반드시 release 빌드로 재설치해 같은 재현 절차로 재검증**한다(debug 빌드 통과만으로 해결됐다고 판단하지 않는다).

## 6. 마무리

- 검증 완료 후 커밋은 사용자가 명시적으로 요청한 경우에만 한다.
- release apk/ipa 산출물(`build/app/outputs/...`, `build/ios/iphoneos/Runner.app`)은 git 추적 대상이 아니므로 별도 정리 불필요.
- 기기에 남은 release 빌드를 debug로 되돌릴 필요는 보통 없지만, 이후 `flutter run`으로 개발을 이어갈 예정이면 그때 자연스럽게 debug 빌드로 덮어써진다.
