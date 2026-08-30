# Money Mate

가계부와 자산 관리를 한 곳에서 관리할 수 있는 개인 가계부 Flutter 앱입니다.

<p>
  <a href="https://play.google.com/store/apps/details?id=com.peter.money_mate">
    <img src="https://play.google.com/intl/en_us/badges/static/images/badges/ko_badge_web_generic.png" alt="Google Play에서 다운로드" height="56"/>
  </a>
  <a href="https://apps.apple.com/kr/app/%EB%82%B4%EB%8F%88%EC%96%B4%EB%94%94-%EA%B0%80%EA%B3%84%EB%B6%80-%ED%9A%8C%EC%9B%90%EA%B0%80%EC%9E%85-%EC%97%86%EB%8A%94-%EC%8B%AC%ED%94%8C%ED%95%9C-%EC%88%98%EB%8F%99-%EA%B0%80%EA%B3%84%EB%B6%80/id6792507401">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="App Store에서 다운로드" height="56"/>
  </a>
</p>

## 스크린샷

| 가계부 | 자산 관리 | 다크 모드 |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/bf0ff9af-3ed7-40c5-945e-36f9fbd6c5c2" width="200"/> | <img src="https://github.com/user-attachments/assets/935cd646-6d3c-4c35-9365-cdf0ba11e6d7" width="200"/> | <img src="https://github.com/user-attachments/assets/88db61bc-61e6-4d00-93ca-7c979632c62f" width="200"/> |

## 주요 기능

- **가계부**: 수입/지출 내역 기록 및 관리
- **자산 관리**: 자산 카테고리별 등록 및 포트폴리오 비중 시각화, 목표 비중 설정
- **즐겨찾기**: 자주 쓰는 항목 즐겨찾기 등록
- **다중 통화 지원**: 주 통화 설정 및 통화별 자산 관리
- **알림**: 로컬 알림을 통한 기록 리마인더
- **다국어 지원**: 한국어(기본), 영어
- **라이트/다크 모드**: 시스템 테마 대응
- **가로모드/큰글씨 대응**

## 기술 스택

- **Framework**: Flutter (Dart 3.7.2+)
- **아키텍처**: Clean Architecture (UI → ViewModel → Repository → DataSource → Database)
- **상태 관리**: `ChangeNotifier` + `Provider`
- **로컬 데이터베이스**: [Drift](https://pub.dev/packages/drift) (SQLite ORM)
- **분석/모니터링**: Firebase Analytics, Firebase Crashlytics
- **알림**: `flutter_local_notifications`

## 프로젝트 구조

```
lib/
├── main.dart                      # 앱 진입점, 탭 내비게이션
├── data/
│   ├── local/                     # Drift/SQLite 데이터베이스 레이어
│   ├── model/entities/            # 도메인 모델 (LedgerEntry, AssetEntry 등)
│   └── repositories/              # Repository 패턴 (추상 + 구현체)
└── ui/
    ├── core/                      # 공통 위젯, 디자인 시스템, 색상 토큰
    ├── ledger/                    # 가계부 기능
    │   ├── view_models/
    │   └── widgets/
    ├── asset/                     # 자산 관리 기능
    │   ├── view_models/
    │   └── screen/
    └── more/                      # 설정 및 기타 화면
```
