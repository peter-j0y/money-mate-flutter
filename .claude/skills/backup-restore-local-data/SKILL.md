---
name: backup-restore-local-data
description: Back up and restore the local SQLite database (가계부/자산 데이터) on a connected iOS or Android test device before doing something destructive — app삭제/재설치, 앱 데이터 초기화(pm clear), flutter clean 등. Use whenever the user asks to back up local/app data, wants to safely reinstall/clear a test device without losing data, or asks to restore previously backed-up data.
---

# 로컬 앱 데이터 백업/복원 (money_mate)

이 앱은 회원가입 없이 로컬 SQLite(`money_mate.sqlite`)에만 데이터를 저장한다. 앱 삭제, `pm clear`, 컨테이너 초기화 같은 실험을 하면 개발용 테스트 데이터가 통째로 날아간다. 이 스킬은 그 전에 데이터를 기기에서 Mac으로 꺼내 백업하고, 필요할 때 다시 밀어넣는다.

## 중요: 플랫폼별 패키지 식별자가 다르다

**Android와 iOS의 앱 식별자가 서로 다르다.** 이걸 헷갈리면 `run-as: unknown package` 같은 오류가 난다.

- **Android applicationId**: `com.peter.money_mate` (밑줄 있음) — `android/app/build.gradle.kts`
- **iOS bundle identifier**: `com.peter.moneyMate` (밑줄 없음, 카멜케이스) — `ios/Runner.xcodeproj/project.pbxproj`의 `PRODUCT_BUNDLE_IDENTIFIER`

## 백업 파일 저장 위치

`~/Desktop/money_mate_backups/<platform>_<YYYYMMDD_HHMMSS>.sqlite` 형식으로 저장한다. (Mac 로컬이라 프로젝트 git에는 포함되지 않음.)

---

## iOS (실기기, `xcrun devicectl` 사용)

Xcode 15+의 CoreDevice(`devicectl`)를 쓴다. 시뮬레이터가 아니라 실기기 기준이다.

### 0. 기기 확인
```bash
xcrun devicectl list devices
```
`Identifier` 컬럼의 UUID를 이후 `--device`에 사용한다. `available (paired)` 상태가 아니면 기기 잠금 해제 후 다시 시도.

### 1. 백업 (Documents 폴더 전체를 꺼내온다)
```bash
mkdir -p ~/Desktop/money_mate_backups
DEVICE_ID="<위에서 확인한 UUID>"
DEST="/tmp/ios_app_data_pull"
rm -rf "$DEST" && mkdir -p "$DEST"

xcrun devicectl device copy from \
  --device "$DEVICE_ID" \
  --domain-type appDataContainer \
  --domain-identifier com.peter.moneyMate \
  --source "Documents" \
  --destination "$DEST"

cp "$DEST/money_mate.sqlite" ~/Desktop/money_mate_backups/ios_$(date +%Y%m%d_%H%M%S).sqlite
```
- `--source "/"` (컨테이너 루트)는 내부 메타데이터 plist 권한 문제로 실패하는 경우가 있다. 반드시 `Documents`(또는 필요시 `Library`, `tmp`)처럼 서브디렉토리를 지정한다.
- `-wal`/`-shm` 파일이 같이 있으면 함께 복사한다(드물게 존재).

### 2. 복원
앱을 먼저 완전히 종료(백그라운드에서도 실행 중이면 안 됨)한 뒤:
```bash
xcrun devicectl device process list --device "$DEVICE_ID" | grep -i moneyMate
# 위에서 아무것도 안 나와야 안전하게 덮어쓸 수 있다.

xcrun devicectl device copy to \
  --device "$DEVICE_ID" \
  --domain-type appDataContainer \
  --domain-identifier com.peter.moneyMate \
  --source ~/Desktop/money_mate_backups/<백업파일명>.sqlite \
  --destination "Documents/money_mate.sqlite"

xcrun devicectl device process launch --device "$DEVICE_ID" com.peter.moneyMate
```

### (참고) 앱 삭제/재설치도 CLI로 가능
```bash
xcrun devicectl device uninstall app --device "$DEVICE_ID" com.peter.moneyMate
flutter build ios --release   # 서명된 빌드 생성 (build/ios/iphoneos/Runner.app)
xcrun devicectl device install app --device "$DEVICE_ID" build/ios/iphoneos/Runner.app
```

### GUI 대안 (CLI 없이)
Xcode → Window → Devices and Simulators → 기기 선택 → 앱 선택 → ⚙️ → **Download Container...**(백업, `.xcappdata`) / **Replace Container...**(복원). 반복 작업이 잦다면 이쪽이 더 간편하다.

---

## Android (`adb` 사용)

Android는 앱 프라이빗 디렉토리를 `adb pull`로 직접 못 읽으므로 `run-as`를 거쳐야 한다.

### 0. 기기 확인
```bash
adb devices
```

### 1. 백업
```bash
mkdir -p ~/Desktop/money_mate_backups
adb exec-out run-as com.peter.money_mate cat /data/data/com.peter.money_mate/app_flutter/money_mate.sqlite \
  > ~/Desktop/money_mate_backups/android_$(date +%Y%m%d_%H%M%S).sqlite
```
- `adb shell run-as ... cat ...` (exec-out이 아닌 일반 shell)은 개행 변환 등으로 바이너리가 깨질 수 있으니 반드시 `exec-out`을 쓴다.
- DB 경로는 `path_provider`의 `getApplicationDocumentsDirectory()`가 Android에서 매핑되는 `app_flutter/money_mate.sqlite`다 (`databases/`가 아님에 주의).

### 2. 복원
`run-as`는 다른 곳에서 온 파일을 자기 프라이빗 디렉토리로 직접 받을 수 없으므로, `/data/local/tmp`에 잠깐 올렸다가 `run-as`로 복사한다.
```bash
adb push ~/Desktop/money_mate_backups/<백업파일명>.sqlite /data/local/tmp/money_mate_restore.sqlite
adb shell run-as com.peter.money_mate sh -c \
  'cp /data/local/tmp/money_mate_restore.sqlite /data/data/com.peter.money_mate/app_flutter/money_mate.sqlite'
adb shell rm /data/local/tmp/money_mate_restore.sqlite
```
복원 전에 앱을 강제 종료해둔다: `adb shell am force-stop com.peter.money_mate`

### (참고) 데이터 초기화/앱 크기 확인
```bash
adb shell pm clear com.peter.money_mate
adb shell "run-as com.peter.money_mate sh -c 'du -ah /data/data/com.peter.money_mate/*'"
```
(글롭 `*`은 반드시 `run-as` 안쪽 `sh -c '...'`에서 확장되게 감싸야 한다. 바깥 zsh가 먼저 확장을 시도해 "no matches found" 오류를 낸다.)

---

## 선택: SharedPreferences(주 통화, 리마인드 설정 등)도 같이 백업하고 싶다면

가계부/자산 데이터는 SQLite에 있지만, 주 통화·리마인드 요일/시간·알림 권한 요청 여부는 SharedPreferences에 저장된다. 완전한 상태 복원이 필요하면 함께 백업한다.

- Android: `/data/data/com.peter.money_mate/shared_prefs/*.xml`
- iOS: `Library/Preferences/com.peter.moneyMate.plist` (appDataContainer 도메인, `Library/Preferences` 서브디렉토리)

## 주의

- 삭제/초기화처럼 되돌릴 수 없는 조작 전에는 항상 먼저 백업하고, 사용자에게 실행 전 확인을 받는다.
- 복원 시 앱이 실행 중이면 파일 잠금/쓰기 충돌이 날 수 있으니 반드시 먼저 종료시킨다.
