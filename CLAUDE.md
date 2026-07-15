# Allowance Manager (아이 용돈 관리 앱)

부모(아빠/엄마)가 각자 안드로이드 폰에서 아이의 용돈을 관리하는 Flutter 앱.
완전 로컬 저장(서버 없음) + 파일 Export/Import 스마트 병합으로 부부간 동기화.
대상 기기: 갤럭시 Z 폴드7 / 플립5 (안드로이드 전용).

## 개발 환경 (이 PC 기준, 모두 OneDrive 밖 로컬 경로)
- 프로젝트: `C:\dev\son_allowance_app` (⚠️ OneDrive 안에 두지 말 것 — build/ 임시파일이 동기화 충돌을 일으킴)
- Flutter SDK: `C:\dev\flutter`
- Android SDK: `C:\dev\android-sdk`
- JDK 17: `C:\Program Files\Microsoft\jdk-17.0.19.10-hotspot`
- 릴리스 서명 keystore: `C:\dev\son_allowance.jks` (alias `son_allowance`, 비번 `allowance2026`)
  - `android/key.properties`가 이 keystore를 참조 (git에는 커밋 안 함 = .gitignore)

### 명령 실행 시 환경변수 (PowerShell)
```powershell
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.19.10-hotspot"
$env:Path = "C:\dev\flutter\bin;$env:JAVA_HOME\bin;C:\dev\android-sdk\platform-tools;$env:Path"
Set-Location "C:\dev\son_allowance_app"
```

## 자주 쓰는 명령
- 코드 생성(drift 스키마 변경 시 필수): `flutter pub run build_runner build --delete-conflicting-outputs`
- 정적 분석: `flutter analyze`
- 디버그 빌드: `flutter build apk --debug`
- 릴리스 빌드(서명됨): `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
- 기기 목록: `adb devices` (아빠 폰 = `R3CY70FYR4J`, 갤럭시 Z 폴드7)
- 데이터 유지 업데이트 설치: `adb -s R3CY70FYR4J install -r <apk경로>`
  - ⚠️ `flutter install`은 기존 앱을 삭제 후 설치(데이터 손실). 업데이트는 반드시 `adb install -r` 사용.
- 앱 실행: `adb -s R3CY70FYR4J shell am start -n com.family.son_allowance_app/.MainActivity`

## 아키텍처
- 상태관리: Riverpod (`lib/providers/`)
- 로컬 DB: drift(SQLite) — `lib/data/app_database.dart` (+ 생성물 `app_database.g.dart`, 커밋됨)
- 화면: `lib/screens/` — `main_shell`(4탭: 홈/내역/주식이체/설정), `overview`(홈+통계), `ledger`(용돈일정+사용내역), `stock_transfer`, `settings`, `onboarding`, `lock`, `avatar_crop`
- 테마: `lib/theme/app_theme.dart` — 파스텔 + Noto Sans KR, `AppPalette` ThemeExtension
- 서비스: `lib/services/` — export_import(스마트 병합, 방어적 파싱), notification, backup
- 공용 위젯: `lib/widgets/` — ui_kit(TagChip/StatTile/SectionHeader), child_avatar, responsive_scaffold

## DB 스키마 (현재 v6)
테이블: Children, AllowanceSchedules, TransactionEntries, StockTransfers, ChangeLogs, Goals, AllowanceRates.
- 스키마 변경 시: 테이블/컬럼 수정 → `schemaVersion` 증가 → `migration`의 onUpgrade에 addColumn/createTable 추가 → **build_runner 재실행**.
- 시스템 예약 카테고리: `정기용돈`, `절약보너스`, `이자` (사용자 편집 카테고리와 분리).

## 주요 기능
- 정기 용돈: 지급요일 기준 "미지급 예정 1개"만 자동 유지(요일 바꾸면 그 일정 날짜만 이동, 이중지급 방지). 지급/취소 가능(연결된 정기용돈 내역 삭제 = 지급 취소).
- 특별 수입(설날/생일 등) + "받은 사람" 기록. 지출 내역.
- 주식계좌 이체(수동 기록형) + 누적 이력.
- 통계: 저축비율, 카테고리별 지출, 받은사람별, 월별, **연간 요약**.
- 절약 보너스(조건부, 원버튼) / **저축 이자**(주기별, 원버튼) — Child 테이블에 규칙 저장.
- 저축 목표(위시리스트), 이번 주 예산, 용돈 변경 이력, 백업 리마인더, 주간 리포트 알림.
- Export/Import: 전체 데이터 JSON + 사람이 읽는 요약 txt. id+updatedAt 기준 스마트 병합. 방어적 파싱(구버전 백업도 호환). avatarPath는 기기 로컬이라 동기화 제외.
- 앱 잠금(PIN/생체), 다크모드, 폴드/플립 반응형.

## 주의사항 / 함정
- OneDrive 폴더에서 빌드 금지(파일 잠금 에러). 이 프로젝트는 이미 `C:\dev`로 이동함.
- 빌드 후 파일 잠금이 남으면 `cd android; ./gradlew --stop` 후 재시도.
- drift 부분 컬럼 갱신은 `upsert` 대신 `update().write()` 사용(NOT NULL 제약 회피).
- `com.family.son_allowance_app`가 applicationId. 앱 표시명은 AndroidManifest `android:label` = "Allowance Manager".
