# Moneycraft (아이 용돈·경제교육 앱)

부모(아빠/엄마)가 각자 안드로이드 폰에서 아이의 용돈을 관리하고, 아이는 자기 폰에서
잔액·목표를 보고 경제를 배우는 Flutter 앱. 로컬 저장(drift) + Firebase 실시간 동기화.
대상 기기: 갤럭시 Z 폴드7 / 플립5 (안드로이드 전용).

## 📍 현재 진행 상황 / 다음 할 일 (이어받기용)
현재 버전: **v1.25.4+44** (앱 표시명 "Moneycraft"). 배포된 마지막 버전은 v1.25.3.

- **v1.25.0** — 홈의 "이번 주 용돈"을 `AllowanceHomeCard`로 전환(지급 취소 버튼 제거,
  되돌리려면 내역 탭에서 삭제) + 디자인 토큰 전면 도입 826곳.
- **v1.25.4 작업 중** — 이자 카드에 다음 회차 예상 금액을 작은 글씨로 덧붙였다
  ("다음 달엔 약 341원"). 접힌 미니바에도 둘째 줄로 들어간다(`MiniBar.subtext`).
  지금 잔액으로 계산한 예상치라 "약"을 붙이고, 받는 날 잔액에 따라 달라진다고 적었다.
- **v1.25.3** — ⚠️ **"받은 금액"은 절대 다시 계산하지 말 것.**
  홈 이자 카드가 `computeInterest`의 결과(= 지금 잔액 × 이자율)를 "○○원 받음"으로
  보여줘서, 실제로 87원 받았는데 341원 받았다고 표시됐다. 이자를 받은 뒤 용돈이
  들어와 잔액이 늘면 표시 금액도 같이 부풀어 오르는 구조였다.
  이미 받은 금액은 `AppDatabase.grantedInterestAmount(childId, period)`로 **기록된
  거래에서 읽어온다**. 회귀 테스트 `test/interest_grant_test.dart`.
- **v1.25.2** — 이자 카드를 접으면 **부모님과 약속 카드도 같이 접힌다**.
  약속은 이자율을 올려주는 장치라 이자 카드가 데리고 있는 구조로 합쳤다
  (`InterestHomeCard`가 `PromisesHomeCard`를 품는다). 접힌 미니바에는 연이율 대신
  약속 개수를 보여줘 거기 숨어 있다는 걸 알린다.
  ⚠️ 이자 기능이 꺼져 있거나 이자가 0원이면 약속 카드를 **단독으로** 보여준다.
  아이가 댓글을 남기는 곳이라 이자 사정으로 사라지면 안 된다.
- **v1.25.1** — v1.25.0을 실기기에서 써보고 나온 지적 반영
  - **이체 권장 알림이 잔액 바뀔 때마다 울리던 문제** → 기준액을 넘는 순간 1회만.
    `AppSettings.transferNotified`에 저장하므로 앱을 다시 켜도 안 울리고, 기준액 아래로
    내려가면 풀린다.
  - 홈의 "주식계좌 이체를 고려해보세요" 배너에 **X(닫기)** 추가 → 닫으면 기준액 아래로
    내려갈 때까지 안 뜬다(`transferBannerDismissed`).
  - **홈 카드 간격 통일** — 카드마다 여백이 8/0/5/12/0으로 달랐다. 이제 홈 전용 카드는
    자체 마진 없이(`margin: EdgeInsets.zero`) 두고, `_homeGap()`이 12씩 띄운다.
    숨겨진 카드(`SizedBox.shrink`)는 통과시켜 빈 간격이 남지 않는다.
  - **백업 배너 오표시 수정** — 가족 동기화 중인데도 "아직 백업을 공유한 적이 없어요"가
    떴다. `lastExportedAt`만 보고 `familyCode`를 안 봤던 것.
  - 내역 탭 기본 기간을 **이번 달**로, 칩 순서를 이번 달/지난 달/올해/전체 기간으로.
    제목도 고른 기간을 따라간다.
  - 경제상식 20주제 + 퀴즈 20문제 추가.
  - **남은 일**: 폴드·플립 실기기 확인.

- **플레이스토어 공개 준비 중** (최신 커밋 `0c38d19`, 아직 버전 태그 없음)
  - applicationId를 `com.family.son_allowance_app` → **`com.moneycraft.app`** 으로 변경 (게시 전 확정).
    namespace는 내부 코드 조직용이라 `com.family.son_allowance_app` 그대로 둠 (Gradle에서 둘은 별개).
  - Firebase 프로젝트에 새 패키지명 앱을 등록하고 `google-services.json`에 **두 항목이 공존**하도록 갱신
    → 기존 가족 동기화 데이터 영향 없음.
  - 개인정보처리방침 페이지 `docs/privacy.html` (GitHub Pages로 서빙 예정).
- **남은 일**: 스토어 등록정보(스크린샷·설명), 개인정보처리방침 URL 연결, 내부 테스트 트랙 업로드.
- ⚠️ 스토어 게시 후에는 applicationId를 절대 바꿀 수 없음.

## 개발 환경
- 프로젝트: `C:\dev\son_allowance_app` (⚠️ OneDrive 안에 두지 말 것 — build/ 임시파일이 동기화 충돌)
- **PC마다 경로가 다름**. 아래는 각자 확인 후 사용:
  - 남편 노트북(릴리스 담당): Flutter `C:\dev\flutter`, Android SDK `C:\dev\android-sdk`,
    JDK 17 `C:\Program Files\Microsoft\jdk-17.0.19.10-hotspot`
  - 아내 PC(개발만): Flutter `C:\dev\flutter`, Android SDK `C:\Android\sdk`,
    JDK 17 `C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot`
    → 이 PC는 Gradle이 AF_UNIX 소켓 문제로 실패하므로 `$env:_JAVA_OPTIONS = "-Djdk.net.unixdomain.tmpdir=C:\Android\tmp"` 필수
- **릴리스 서명 keystore는 남편 노트북에만 있음**: `C:\dev\son_allowance.jks` (alias `son_allowance`),
  비밀번호는 `android/key.properties`(git 미포함). **릴리스 빌드·배포는 반드시 남편 노트북에서.**
  키 없이 빌드하면 디버그 키로 서명돼 기존 앱 업데이트가 불가능함.

### 명령 실행 시 환경변수 (PowerShell, 새 터미널마다)
```powershell
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.19.10-hotspot"  # PC에 맞게
$env:Path = "C:\dev\flutter\bin;$env:JAVA_HOME\bin;C:\dev\android-sdk\platform-tools;$env:Path"
Set-Location "C:\dev\son_allowance_app"
```

## 자주 쓰는 명령
- 코드 생성(drift 스키마 변경 시 필수): `dart run build_runner build --delete-conflicting-outputs`
- 정적 분석: `flutter analyze` / 테스트: `flutter test`
- 디버그 빌드: `flutter build apk --debug`
- 릴리스 빌드(서명됨): `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
- 데이터 유지 업데이트 설치: `adb install -r <apk경로>`
  - ⚠️ `flutter install`은 기존 앱 삭제 후 설치(데이터 손실). 업데이트는 반드시 `adb install -r`.
- 릴리스 게시: APK를 `Moneycraft-v<버전>.apk`로 복사 → `git tag v1.x.x && git push origin v1.x.x`
  → `gh release create v1.x.x Moneycraft-v1.x.x.apk --title "Moneycraft v1.x.x" --notes-file <노트>`

## 협업 규칙 (부부 공동 개발)
- 저장소 https://github.com/jong0227/son_allowance_app (소유 jong0227, 아내 vlrgma9는 collaborator).
- **작업 시작 전 반드시 `git fetch && git log origin/main` 으로 최신 확인**하고 최신 main에서 브랜치를 딸 것.
  과거에 옛 main 기준으로 작업해 상대 작업을 통째로 되돌릴 뻔한 사고가 있었음.
- 두 사람이 동시에 작업하므로, 큰 변경은 브랜치 + PR로 올려 상대가 검토 후 머지.
- PC마다 `gh` 로그인 계정이 다를 수 있음. 저장소 작업 전 `gh auth status`로 확인
  (`gh auth switch --user <계정>`으로 전환).

## 아키텍처
- 상태관리: Riverpod (`lib/providers/`)
- 로컬 DB: drift(SQLite) — `lib/data/app_database.dart` (+ 생성물 `app_database.g.dart`, 커밋됨)
- **탭 5개** (`main_shell`): 홈 / 내역 / 주식 / 경제왕 / 설정
- 화면 (`lib/screens/`):
  - `overview`(홈+통계, 최대 파일), `ledger`(용돈일정+사용내역), `stock_transfer`(주식+모의투자),
    `economy`(경제왕 탭), `settings`
  - 경제교육: `quiz`, `quiz_history`, `topic_explainer`, `interest_explainer`, `rates_explainer`,
    `cofix_explainer`, `compound_simulator`
  - 모의투자: `invest`, `invest_detail`
  - 기타: `onboarding`, `lock`, `avatar_crop`, `tier_settings`, `promise_detail`,
    `allowance_history`, `category_history`
- 공용 위젯 (`lib/widgets/`): `ui_kit`(TagChip/StatTile/SectionHeader), 홈 카드
  (`bonus_home_card`, `interest_home_card`, `promises_home_card`), 스트립
  (`market_index_strip`, `rates_strip`, `invest_status_strip`), `tier_widgets`,
  `tier_cinematic`, `interest_celebration`, `child_avatar`, `stock_search`, `responsive_scaffold`
- 테마: `lib/theme/app_theme.dart` — 파스텔 + Noto Sans KR, `AppPalette` ThemeExtension
  (income/expense/savings/special/allowance + tags 팔레트). 카테고리 색은 원 등분 방식으로 배정.

### 디자인 토큰 (v1.25.0~) ⚠️ 새 화면 만들 때 반드시 지킬 것
숫자를 직접 쓰지 말고 `lib/theme/app_theme.dart`의 토큰을 쓴다. 전에는 fontSize가 34가지,
라운드가 12가지로 흩어져 있어서 같은 뜻의 글씨가 화면마다 12 / 12.5 / 13으로 달랐다
(두 사람이 각자 화면을 만들다 보니 더 벌어졌다).

- `AppText` — micro 10 / caption 11 / label 12 / body 13 / bodyLg 14 / title 15 /
  titleLg 16 / heading 18 / numSm 20 / numMd 22 / numLg 24 / numXl 28 / numHero 34
- `AppEmoji` — sm 32 / md 40 / lg 48 / hero 96. 이모지는 읽는 글자가 아니라 그림이라
  글씨 스케일과 섞지 않는다.
- `AppRadius` — xs 6 / sm 10 / md 12 / lg 16(카드 기본) / xl 20
- `AppGap` — 2 / 4 / 6 / 8 / 10 / 12 / 16 / 20 / 24. `SizedBox`와 `EdgeInsets.all`에 쓴다.
- `FontWeight`는 **w600 / w700 / w800 / w900 네 가지만**. `FontWeight.bold`는 w700과 같은
  값인데 이름만 달라 헷갈리므로 쓰지 않는다.

예외로 남겨둔 것:
- `EdgeInsets.symmetric` · `only` · `fromLTRB`는 숫자를 그대로 쓴다. "칩 안쪽 여백 가로 9
  세로 4"처럼 그 컴포넌트에서만 의미 있는 미세조정이라 공통 스케일로 묶으면 뜻이 흐려진다.
- 차트 높이(`SizedBox(height: 520)` 등)도 간격이 아니라 크기라 토큰 대상이 아니다.

애매하면 **한 단계 작은 쪽**을 고른다(폴드·플립 좁은 화면에서 잘리는 걸 피하려고).
"본문 글씨를 키우자" 같은 요구는 `AppText.body` 한 줄만 고치면 앱 전체가 따라온다.
- 데이터 서비스 (`lib/services/`): `export_import`(스마트 병합), `sync`(Firebase), `interest_calc`,
  `rates`(ECOS), `cofix`(은행연합회), `stock_search`(야후), `notification`, `backup`, `update`

## DB 스키마 (현재 v16)
테이블: Children, AllowanceSchedules, TransactionEntries, StockTransfers, ChangeLogs, Goals,
AllowanceRates, Requests, Tiers, **Promises, PromiseComments, QuizAttempts, Investments**.

- **스키마 변경 시**: 테이블/컬럼 수정 → `schemaVersion` 증가 → `migration`의 onUpgrade에
  addColumn/createTable 추가 → **build_runner 재실행** → export_import 직렬화에도 반영(동기화 누락 방지).
- ⚠️ 자녀 부분 컬럼 갱신은 반드시 `updateChildPartial(id, changes)` 사용.
  `upsertChild`는 INSERT 경로에서 name(NOT NULL)이 없으면 실패 → 규칙 편집이 조용히 안 되던 버그 원인.
- v11 Promises(부모-자녀 약속), v13 PromiseComments(약속 댓글/ON·OFF 기록),
  v14 QuizAttempts(퀴즈 풀이), v15 Children.quizReward + QuizAttempts.pickedIndex, v16 Investments(모의투자).
- 시스템 예약 카테고리: `정기용돈`, `절약보너스`, `이자`, `퀴즈보상`, `이월잔액`
  (`AppDatabase.isSystemCategory`로 판별, 받은사람별 통계에서 제외).
- 시작 잔액(이월잔액): computeSummary에서 balance엔 포함하되 수입 통계에선 제외(initialBalance 키로 분리).

## 주요 기능
### 용돈 관리
- 정기 용돈: 마지막 지급일 이후 매주 백필 → 못 준 주는 "밀린 용돈"으로 표시. 개별/일괄 지급,
  "건너뛰기"(영구 제외) 가능. 같은 날짜 중복 일정 자동 정리. 백필 최대 12건.
  로직 테스트 `test/schedule_logic_test.dart`.
- 특별 수입(설날/생일) + "받은 사람" 기록, 지출 내역, 주식계좌 이체(수동 기록형).
- 절약 보너스(조건부), 저축 목표(위시리스트), 이번 주 예산, 용돈 변경 이력.
- 통계: 저축비율, 카테고리별/받은사람별/월별/연간 요약.

### 저축 이자 (`lib/services/interest_calc.dart`)
- 이자율 = **실제 은행 정기예금 금리(ECOS) × 배수(기본 1)** = 은행과 동일 수준.
  약속 1개당 **연 +0.3%p**. 표기는 "은행의 N배" 대신 **연이율 + 이번 회차 금액(원)**.
- 지급 주기 기본 **매주**. 아이도 직접 "받기" 가능(동전 축하 연출).
  아무도 안 누르고 주가 넘어가면 **직전 주기분 자동 지급** 후 앱 열 때 축하 연출.
- ⚠️ 이자 내역 id는 `int_{childId}_{yyyymmdd}` **고정** — 두 기기가 각자 자동지급해도 한 건으로 합쳐짐.
  같은 행을 덮어쓰므로 `_writeInterestTx`에서 **`deletedAt`을 반드시 null로 비울 것**
  (안 비우면 지급 취소 후 재지급 시 내역이 영영 안 보임). 회귀 테스트 `test/interest_grant_test.dart`.
- 예금금리는 기기에 캐시 → 오프라인에서도 계산, 못 받아오면 고정 이율로 폴백.

### 경제교육 (경제왕 탭)
- **퀴즈**: 주 1회 3문제, 정답 시 자녀별 설정 보상(`Children.quizReward`) 자동 적립.
  틀리면 **해설 5초 이상 읽어야** 재도전 열리고, 재도전 시 **보기 순서를 섞어** 위치 암기 방지.
  재도전 정답은 절반 지급. 문제은행 **166개**(`lib/data/quiz_bank.dart`), 한 번 푼 문제는 재출제 안 함.
  남은 문제 5개 이하면 부모에게 안내. 기록 화면에서 보기·고른 답·해설 확인(남은 문제는 부모만).
- **경제상식**: **67주제**(`lib/data/economy_topics.dart`) — 데이터만 추가하면 화면은 공용 렌더러 재사용.
  초등 2~6학년 눈높이. 뒤쪽 20개는 생활 밀착 주제(구독료, 게임 확률형 아이템, 중고거래,
  온라인 사기, 저작권, 세뱃돈 관리, 용돈 협상 등)로, 퀴즈 `q4_01`~`q4_20`과 짝을 이룬다.
  "오늘의 경제상식" 1개 로테이션 + 읽음 체크/진행률(기기 로컬 저장).
- **복리 시뮬레이터**: 매주 저축액·기간 조절 → 미래 금액 그래프, 약속 지킬 때/안 지킬 때 비교.
- **지표**: 홈에 코스피/코스닥/나스닥 지수 + 기준금리·정기예금·COFIX. 경제왕 탭에 물가상승률·환율.
  - ECOS(한국은행) 인증키는 `cofix_provider.dart`의 `kDefaultEcosApiKey`에 내장(무료 키).
  - COFIX는 ECOS에 없어 **은행연합회 페이지 파싱**(키 불필요). 헤더/meta 인코딩이 어긋나 있어
    latin1 디코딩 + ASCII 전용 정규식으로 파싱. 대출 기능 만들 때 재사용 예정.

### 모의 투자 (주식 탭)
- 저축 포인트로 세계 지수 7개(코스피/코스닥/나스닥/인도/중국/베트남/유럽)에 투자 연습.
- Investments 테이블에 매수 시점 지수값 저장 → 현재 지수와 비교해 손익/수익률 계산. 강제청산 없음.
- 테스트 `test/invest_test.dart`.

### 티어(등급)
- Tiers 테이블: kind='savings'(누적 저축액, 마인크래프트 테마 27단계) / 'weekly'(주간 저축률).
  기본값은 앱 시작 시 시드(고정 과거 updatedAt=2020이라 부모 수정이 항상 동기화 우선).
- 등급 아이콘 **7번 연속 탭 = 이스터에그**: 블럭 폭발 → 6.2초 시네마틱
  (블럭 낙하 → 채굴 → 파괴 → 아이템 등장 → 폭죽). 코드로 그려서 APK 용량 증가 없음.
  티어 27종 고유 색, 다이아 이상은 무지갯빛. `lib/widgets/tier_cinematic.dart`.

### 동기화 · 보안
- **실시간 자동 동기화 (Firebase)**: `lib/services/sync_service.dart`. Firestore `kids-allowance-48c8e`,
  문서 하나(`families/{6자리코드}`)에 `serializeAll()` 결과를 통째로 저장.
  익명 로그인 + `db.tableUpdates()` 구독으로 자동 업로드(디바운스 1.2s), `snapshots()`로 자동 병합.
  병합은 Export/Import의 id+updatedAt 로직 재사용. 신호값 비교로 자기 변경의 반향을 걸러냄.
  Firestore 규칙은 `request.auth != null`만 요구(가족 코드가 사실상의 비밀번호).
  google-services.json은 공개 저장소에 커밋됨(클라이언트 설정은 비밀 아님, 보안은 Rules 담당).
- Export/Import: 전체 JSON + 사람이 읽는 요약 txt. 방어적 파싱(구버전 백업 호환).
  avatarPath는 기기 로컬이라 동기화 제외.
- **자녀 모드(deviceOwner='아들')**: 지급/승인/규칙편집/이체추가 UI 숨김(`AppSettings.isChild`).
  본인 지출 기록·잔액/통계 조회·요청·이자 받기·퀴즈 가능.
- **부모 암호**: 자녀가 부모 모드로 전환하는 걸 막는 4~6자리. 해시+salt만 보관하고
  가족 문서 top-level `parentPasscode`로 전파.
- 앱 잠금(PIN/생체), 다크모드, 폴드/플립 반응형.

## 주의사항 / 함정
- OneDrive 폴더에서 빌드 금지(파일 잠금 에러).
- 빌드 후 파일 잠금이 남으면 `cd android; ./gradlew --stop` 후 재시도.
- drift 부분 컬럼 갱신은 `upsert` 대신 `update().write()` 사용(NOT NULL 제약 회피).
- drift Table에서 `text`는 예약어 — 컬럼명으로 쓸 수 없음(PromiseComments는 `message`로 우회).
- 스키마를 바꾸면 export_import_service의 직렬화/역직렬화에도 **반드시** 반영할 것(동기화 누락).
- applicationId `com.moneycraft.app`, namespace `com.family.son_allowance_app`, 표시명 "Moneycraft".
