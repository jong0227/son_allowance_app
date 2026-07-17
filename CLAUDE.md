# Allowance Manager (아이 용돈 관리 앱)

부모(아빠/엄마)가 각자 안드로이드 폰에서 아이의 용돈을 관리하는 Flutter 앱.
완전 로컬 저장(서버 없음) + 파일 Export/Import 스마트 병합으로 부부간 동기화.
대상 기기: 갤럭시 Z 폴드7 / 플립5 (안드로이드 전용).

## 📍 현재 진행 상황 / 다음 할 일 (이어받기용)
현재 버전: **release v1.3** (앱 표시명 "Allowance Manager").
- 완료: 전체 기능 구현, 파스텔 UI, 저축이자/보너스/목표/연간통계/내역검색, 동기화 버그(기기별 중복 프로필 통합) 수정.
- 아빠 폰(Fold7, adb id `R3CY70FYR4J`)엔 v1.3 설치 예정이었으나 **기기 미연결로 대기 중**. 연결되면 `adb -s R3CY70FYR4J install -r <apk>`로 업데이트(데이터 유지).
- 아내 폰 배포용: 바탕화면에 `AllowanceManager_v1.3.apk` / `AllowanceManager_v1.3.zip`(카톡용) 준비됨.
- **GitHub 연결 완료**: 공개 저장소 https://github.com/jong0227/son_allowance_app (계정 jong0227, gh CLI 인증됨). `git push`로 업로드.
- 릴리스 서명 비밀번호는 로컬 `android/key.properties`에 있음(git 미포함). 다른 PC로 옮기면 keystore(`C:\dev\son_allowance.jks`)와 key.properties를 수동 복사해야 릴리스 빌드 가능.

## 개발 환경 (이 PC 기준, 모두 OneDrive 밖 로컬 경로)
- 프로젝트: `C:\dev\son_allowance_app` (⚠️ OneDrive 안에 두지 말 것 — build/ 임시파일이 동기화 충돌을 일으킴)
- Flutter SDK: `C:\dev\flutter`
- Android SDK: `C:\dev\android-sdk`
- JDK 17: `C:\Program Files\Microsoft\jdk-17.0.19.10-hotspot`
- 릴리스 서명 keystore: `C:\dev\son_allowance.jks` (alias `son_allowance`, 비밀번호는 `android/key.properties`에 있음)
  - `android/key.properties`가 이 keystore를 참조 (비밀번호 포함, git에는 커밋 안 함 = .gitignore)

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

## DB 스키마 (현재 v7)
테이블: Children, AllowanceSchedules, TransactionEntries, StockTransfers, ChangeLogs, Goals, AllowanceRates, Requests.
- 스키마 변경 시: 테이블/컬럼 수정 → `schemaVersion` 증가 → `migration`의 onUpgrade에 addColumn/createTable 추가 → **build_runner 재실행**.
- 시스템 예약 카테고리: `정기용돈`, `절약보너스`, `이자`, `이월잔액` (`AppDatabase.isSystemCategory`로 판별, 받은사람별 통계에서 제외). 사용자 편집 카테고리와 분리.
- Requests: 자녀→부모 요청(type='bonus'|'wishlist', status pending/approved/rejected). 승인 시 보너스 수입/저축 목표 자동 생성. 동기화 직렬화에 포함됨.

## 주요 기능
- 정기 용돈 (v1.4 개편): 마지막 지급일 이후 매주 지급일마다 일정 백필 → 못 준 주는 "밀린 용돈"으로 표시(홈 요약 + 내역 탭). 개별/일괄 지급, "건너뛰기"(영구 제외, 소프트 삭제) 가능. 밀린 지급 시 내역 메모에 원래 예정일 기록. 같은 날짜 중복 일정은 자동 정리(동기화 안전). 지급요일 변경 시 미래 예정만 이동, 밀린 건 유지. 백필 최대 12건. 로직 테스트: `test/schedule_logic_test.dart`. 지급/취소 가능(연결된 정기용돈 내역 삭제 = 지급 취소).
- 특별 수입(설날/생일 등) + "받은 사람" 기록. 지출 내역.
- 주식계좌 이체(수동 기록형) + 누적 이력.
- 통계: 저축비율, 카테고리별 지출, 받은사람별, 월별, **연간 요약**.
- 절약 보너스(조건부, 원버튼) / **저축 이자**(주기별, 원버튼) — Child 테이블에 규칙 저장.
- 저축 목표(위시리스트), 이번 주 예산, 용돈 변경 이력, 백업 리마인더, 주간 리포트 알림.
- Export/Import: 전체 데이터 JSON + 사람이 읽는 요약 txt. id+updatedAt 기준 스마트 병합. 방어적 파싱(구버전 백업도 호환). avatarPath는 기기 로컬이라 동기화 제외.
- **실시간 자동 동기화 (Firebase)**: `lib/services/sync_service.dart`. Firestore 프로젝트 `kids-allowance-48c8e`, 문서 하나(`families/{6자리코드}`)에 `serializeAll()` 결과를 통째로 저장하는 방식(테이블별 서브컬렉션 아님). 익명 로그인(firebase_auth) + `db.tableUpdates()` 구독으로 로컬 변경 시 자동 업로드(디바운스 1.2s), Firestore `snapshots()` 구독으로 원격 변경 자동 병합. 기존 Export/Import의 id+updatedAt 병합 로직(`ExportImportService.previewImportData/applyImport`)을 그대로 재사용. 신호값(정렬된 JSON 문자열) 비교로 자기 자신이 올린 변경의 반향을 걸러냄. Firestore 보안 규칙: `request.auth != null`만 요구(가족 코드가 사실상의 비밀번호 역할). google-services.json은 공개 저장소에 커밋됨(Firebase 클라이언트 설정은 비밀 아님, 실제 보안은 Rules가 담당 — Google 공식 가이드).
- 앱 잠금(PIN/생체), 다크모드, 폴드/플립 반응형.
- **자녀 모드(deviceOwner='아들')**: 온보딩에서 아들 선택 시 가족 코드로 join. 지급/승인/규칙편집/이체추가/시작잔액 UI 숨김(`AppSettings.isChild`). 본인 지출 기록·잔액/통계 조회·보너스 요청·위시리스트 요청 가능. 부모 홈에 "요청함"(승인/거절), 자녀 홈에 "내 요청".
- **부모 암호(parentPasscode)**: 자녀가 부모 모드로 전환하는 걸 막는 4~6자리 암호. 해시(hash+salt)만 보관하고 가족 Firestore 문서 top-level `parentPasscode` 필드로 전파(child도 해시만 받아 검증만 가능, 원문은 모름). 설정 > 부모 암호에서 설정, 즉시 `sync.pushNow()`로 전파. 미설정 상태면 전환 허용(초기).

## 주의사항 / 함정
- OneDrive 폴더에서 빌드 금지(파일 잠금 에러). 이 프로젝트는 이미 `C:\dev`로 이동함.
- 빌드 후 파일 잠금이 남으면 `cd android; ./gradlew --stop` 후 재시도.
- drift 부분 컬럼 갱신은 `upsert` 대신 `update().write()` 사용(NOT NULL 제약 회피).
- `com.family.son_allowance_app`가 applicationId. 앱 표시명은 AndroidManifest `android:label` = "Allowance Manager".
