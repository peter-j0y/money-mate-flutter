---
name: bump-version
description: Bump the money_mate app version in pubspec.yaml and refresh Flutter's generated build caches so Xcode/Android Studio immediately pick up the new version instead of showing a stale one. Use whenever the user asks to change, update, or bump the app version (e.g. "버전 1.2.0(4)로 변경해줘", "버전 올려줘").
---

# 앱 버전 올리기 (money_mate)

`pubspec.yaml`의 `version:` 한 줄만 바꾸는 걸로는 끝나지 않는다. iOS는 `ios/Flutter/Generated.xcconfig`에 버전이 캐시되어 있고, 이 파일은 `flutter pub get`만으로는 갱신되지 않아서 Xcode가 예전 버전으로 계속 빌드하는 문제가 생긴다. 이 스킬은 그 캐시까지 확실히 갱신한다.

## 절차

1. **새 버전 확정**
   - 사용자가 `1.2.0+4`, `1.2.0(4)`, `1.2.0 빌드 4` 등으로 버전을 지정하면 `<versionName>+<buildNumber>` 형태로 파싱한다.
   - 버전을 지정하지 않았다면 `pubspec.yaml`의 현재 `version:` 값을 읽고, versionName은 그대로 두고 buildNumber만 +1 해서 사용할지 사용자에게 확인한다.

2. **`pubspec.yaml` 수정**
   - `version: X.Y.Z+N` 줄을 Edit 도구로 정확히 교체한다. (파일 상단 주석에 있는 버전 설명은 건드리지 않는다.)

3. **`flutter pub get` 실행**
   - 의존성 캐시를 정리하는 차원에서 실행한다. 이것만으로는 iOS 캐시가 갱신되지 않으므로 다음 단계가 필수다.

4. **iOS 빌드 캐시 갱신 (필수)**
   - `flutter build ios --config-only` 실행. 실제 컴파일 없이 `ios/Flutter/Generated.xcconfig`만 재생성한다.
   - 이 파일은 `ios/.gitignore`에 의해 git에서 제외되므로 커밋 대상이 아니다.
   - 갱신 확인: `grep "FLUTTER_BUILD_NAME\|FLUTTER_BUILD_NUMBER" ios/Flutter/Generated.xcconfig` 로 새 버전이 반영됐는지 확인한다.

5. **Android 확인 (참고용, 별도 조치 불필요)**
   - Android는 Gradle이 빌드할 때마다 `pubspec.yaml`을 직접 읽어 `flutter.versionName`/`flutter.versionCode`를 구성하므로 iOS 같은 캐시 문제가 없다. 굳이 추가로 할 일은 없다.

6. **결과 보고**
   - 변경된 버전과 갱신된 `Generated.xcconfig` 값을 함께 보여준다.
   - **커밋은 자동으로 하지 않는다.** 사용자가 별도로 "커밋해줘"라고 요청하면 그때 커밋한다.

## 참고

- `flutter build ios --config-only`는 코드사이닝이나 실제 빌드 없이 설정 파일만 재생성하므로 빠르고 안전하다.
- 버전을 여러 번 연속으로 바꿀 일이 있다면 마지막에 한 번만 이 스킬을 실행해도 된다 (매번 실행할 필요 없음).
