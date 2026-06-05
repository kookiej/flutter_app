# Flutter 변환 설명서 — ._. Music App

이 문서는 `Login.html`, `Home.html`, `Search.html`, `Player.html` (React + inline styles 프로토타입) 을 **Flutter 앱**으로 1:1 포팅하기 위한 사양서입니다.
모든 색상값, 폰트, 간격, 애니메이션 타이밍, 인터랙션을 그대로 재현하는 것을 목표로 합니다.

---

## 0. Claude Code 에게 처음 시킬 프롬프트 (복붙용)

> 첨부된 `FLUTTER_SPEC.md` 와 4개의 HTML 프로토타입 파일(`Login.html`, `Home.html`, `Search.html`, `Player.html`)을 참고해서 Flutter 앱을 만들어줘.
> - `FLUTTER_SPEC.md` 에 정의된 폴더 구조, DTO, 상태관리, 디자인 토큰, 컴포넌트, 화면별 사양을 **그대로** 따라야 해.
> - 색상값, 폰트, 간격(px → logical pixel 1:1), 애니메이션 곡선과 duration, 인터랙션(스와이프, 드래그, 오버레이 전환) 모두 HTML 과 동일하게 재현해.
> - 임의로 단순화하거나 생략하지 마. 모르겠는 부분이 있으면 HTML 소스를 직접 읽고 동작을 확인해.
> - 우선 `pubspec.yaml`, 폴더 구조, 디자인 토큰, 모델, Provider 부터 만들고, 그 다음에 화면을 순서대로 (Login → Home → Search → Player) 구현해.

---

## 1. 앱 개요

- **앱 이름**: `._.` (점-언더스코어-점, 음악 팬용 스트리밍 앱)
- **타겟**: iOS / Android (모바일 only, 세로 고정)
- **언어**: 한국어 (ko_KR)
- **최소 SDK**: Flutter 3.19+, Dart 3.3+
- **디자인 폭 기준**: 430 logical px (iPhone 14 Pro Max 폭)
- **다크 테마 only** (배경 `#0a0a0f`)

### 화면 4개
| 라우트 | 파일 | 기능 |
|---|---|---|
| `/login` | `LoginPage` | 이메일/비번 로그인 + 소셜 로그인 |
| `/home` | `HomePage` | 추천 트랙, 최근 재생, 아티스트 |
| `/search` | `SearchPage` | 검색 + 장르/무드 탐색 |
| `/player` | `PlayerPage` | 풀스크린 플레이어 (오버레이 슬라이드업) |

플레이어는 Home/Search 위에 **bottom-sheet 형태로 슬라이드업** 되며, **별도 라우트가 아닌 모달 오버레이** 입니다.

---

## 2. 필수 패키지 (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  provider: ^6.1.2                # 상태관리 (currentSong, queue, isPlaying)
  shared_preferences: ^2.2.3      # localStorage 대체
  google_fonts: ^6.2.1            # Noto Sans KR, Noto Serif KR, DM Mono
  flutter_svg: ^2.0.10            # SVG 아이콘 (HTML 의 inline SVG 대체)
```

> 라우팅은 `go_router` 없이 기본 `Navigator` 로 충분 (화면 4개).
> 애니메이션은 `flutter` 기본 `AnimatedContainer`, `AnimationController`, `Tween`, `SlideTransition` 으로 모두 처리 가능.

---

## 3. 폴더 구조

```
lib/
├── main.dart
├── app.dart                          # MaterialApp + 라우트
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart           # 색상 토큰 (아래 §5)
│   │   ├── app_text_styles.dart      # 폰트 스타일 토큰
│   │   ├── app_spacing.dart          # 간격, radius
│   │   └── app_durations.dart        # 애니메이션 duration / curve
│   └── utils/
│       ├── time_format.dart          # formatTime(seconds) → "m:ss"
│       └── greeting.dart             # 시간대별 인사말
│
├── data/
│   ├── models/
│   │   ├── song.dart                 # Song DTO
│   │   ├── artist.dart               # Artist DTO
│   │   ├── genre.dart                # Genre DTO
│   │   ├── mood.dart                 # Mood DTO
│   │   ├── lyric_line.dart           # LyricLine DTO
│   │   └── app_notification.dart     # Notification DTO
│   ├── mock/
│   │   ├── songs.dart                # SONGS 상수 (10곡)
│   │   ├── artists.dart              # ARTISTS 상수 (5팀)
│   │   ├── genres.dart               # GENRES 상수 (8개)
│   │   ├── moods.dart                # MOODS 상수 (4개)
│   │   ├── lyrics.dart               # LYRICS, FANCHANT
│   │   └── notifications.dart        # MOCK_NOTIFS
│   └── repositories/
│       └── player_storage.dart       # SharedPreferences 래퍼
│
├── providers/
│   ├── player_provider.dart          # 현재 곡, 큐, 재생 상태, 시크 등
│   ├── search_provider.dart          # 검색어, 결과, 최근 검색
│   └── notification_provider.dart    # 알림 목록, 읽음 처리
│
├── features/
│   ├── login/
│   │   ├── login_page.dart
│   │   └── widgets/
│   │       ├── input_field.dart
│   │       ├── social_button.dart
│   │       └── logo_mark.dart
│   ├── home/
│   │   ├── home_page.dart
│   │   └── widgets/
│   │       ├── home_header.dart
│   │       ├── featured_card.dart
│   │       ├── chip_filter_row.dart
│   │       ├── song_row.dart
│   │       ├── artist_card.dart
│   │       ├── compact_card.dart
│   │       └── section_header.dart
│   ├── search/
│   │   ├── search_page.dart
│   │   └── widgets/
│   │       ├── search_input.dart
│   │       ├── recent_search_row.dart
│   │       ├── genre_grid.dart
│   │       ├── mood_row.dart
│   │       └── song_result_row.dart
│   ├── player/
│   │   ├── player_page.dart
│   │   └── widgets/
│   │       ├── album_cover.dart
│   │       ├── lyrics_panel.dart
│   │       ├── progress_bar.dart
│   │       ├── control_buttons.dart
│   │       └── queue_sheet.dart
│   └── shared/
│       ├── widgets/
│       │   ├── mini_cover.dart           # 작은 앨범 아트
│       │   ├── large_cover.dart          # 큰 앨범 아트 (vinyl 효과)
│       │   ├── mini_player_bar.dart      # 하단 미니 플레이어
│       │   ├── bottom_nav_bar.dart       # 하단 4 탭 네비
│       │   ├── profile_panel.dart        # 우측 슬라이드 프로필 패널
│       │   ├── toast_snackbar.dart       # 토스트
│       │   └── noise_overlay.dart        # 전체 노이즈 텍스처
│       └── icons/
│           └── app_icons.dart            # 모든 SVG 아이콘 위젯
```

---

## 4. DTO (모델)

### 4.1 `Song` — `lib/data/models/song.dart`

HTML 의 `SONGS` 배열과 1:1 대응. 모든 색상은 `Color` 로 변환.

```dart
class Song {
  final String title;
  final String artist;
  final String album;
  final int duration;          // 초 단위
  final List<Color> colors;    // 길이 3 (배경 그라데이션용 dark → mid → vivid)
  final Color accent;          // UI 강조색
  final Color lyricsColor;     // 가사 색
  final List<Color> coverGradient;  // 앨범 커버 그라데이션 (135deg, 3-stop)
  final Color coverAccent;     // 앨범 커버 메인색
  final List<String> tags;     // 검색용 태그 (Home/Player 곡엔 없고 Search 만 있음)

  const Song({
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.colors,
    required this.accent,
    required this.lyricsColor,
    required this.coverGradient,
    required this.coverAccent,
    this.tags = const [],
  });
}
```

**10곡 데이터** — `lib/data/mock/songs.dart` 에 상수로 (HTML SONGS 배열 그대로):

| # | title | artist | album | duration | accent | coverAccent |
|---|---|---|---|---|---|---|
| 0 | Dynamite | BTS | BE | 199 | `#a78bfa` | `#7c3aed` |
| 1 | Celebrity | IU | LILAC | 213 | `#f0abfc` | `#c026d3` |
| 2 | After LIKE | IVE | After Like | 178 | `#4ade80` | `#16a34a` |
| 3 | Hype Boy | NewJeans | NewJeans | 175 | `#60a5fa` | `#2563eb` |
| 4 | Nxde | (G)I-DLE | I love | 192 | `#fb923c` | `#ea580c` |
| 5 | ANTIFRAGILE | LE SSERAFIM | ANTIFRAGILE | 185 | `#facc15` | `#ca8a04` |
| 6 | LOVE DIVE | IVE | LOVE DIVE | 172 | `#818cf8` | `#4338ca` |
| 7 | Butter | BTS | Butter | 164 | `#fbbf24` | `#d97706` |
| 8 | Savage | aespa | Savage | 227 | `#2dd4bf` | `#0d9488` |
| 9 | Queencard | (G)I-DLE | I feel | 193 | `#f472b6` | `#db2777` |

전체 `colors`, `lyricsColor`, `coverGradient` 등은 `Home.html` 의 `SONGS` 배열을 그대로 옮길 것.

**Search 화면용 tags** (`Search.html` ALL_SONGS 참고):
- Dynamite: `["k-pop","댄스","영어"]`
- Celebrity: `["k-pop","발라드","감성"]`
- After LIKE: `["k-pop","댄스","걸그룹"]`
- Hype Boy: `["k-pop","하이브리드","걸그룹"]`
- Nxde: `["k-pop","걸그룹","컨셉"]`
- ANTIFRAGILE: `["k-pop","걸그룹","파워"]`
- LOVE DIVE: `["k-pop","걸그룹","감성"]`
- Butter: `["k-pop","댄스","영어"]`
- Savage: `["k-pop","걸그룹","미래적"]`
- Queencard: `["k-pop","걸그룹","자신감"]`

### 4.2 `Artist`

```dart
class Artist {
  final String name;
  final Color color;
  final int songs;
  const Artist({required this.name, required this.color, required this.songs});
}
```

데이터 (`Home.html` ARTISTS 그대로):
- `{name:"BTS", color:0xFF7c3aed, songs:3}`
- `{name:"IU", color:0xFFc026d3, songs:5}`
- `{name:"IVE", color:0xFF16a34a, songs:2}`
- `{name:"NewJeans", color:0xFF2563eb, songs:4}`
- `{name:"(G)I-DLE", color:0xFFea580c, songs:3}`

### 4.3 `Genre`

```dart
class Genre {
  final String label;
  final Color color;
  final List<Color> bgGradient;  // 2-stop 135deg
}
```

8개 (`Search.html` GENRES): K-POP, 발라드, 댄스, 인디, 로파이, 팝, OST, R&B

### 4.4 `Mood`

```dart
class Mood {
  final String label;
  final String icon;  // ✦ ◈ ◎ ◇
  final int songs;
}
```

4개: 지금 기분(✦,12), 운동할 때(◈,24), 집중할 때(◎,18), 드라이브(◇,15)

### 4.5 `LyricLine`

```dart
class LyricLine {
  final int time;   // 초
  final String text;
}
```

`LYRICS` (10줄, 영문 Dynamite 가사) 와 `FANCHANT` (10줄, 한글 팬챈트) — `Player.html` 그대로.

### 4.6 `AppNotification`

```dart
class AppNotification {
  final int id;
  final String text;
  final String time;     // "방금 전", "1시간 전" 등 (사전 포맷된 문자열)
  final bool read;
}
```

기본 3개 (Home/Search MOCK_NOTIFS):
1. id:1, "BTS의 새 앨범이 출시됐어요", "방금 전", read:false
2. id:2, "IU Celebrity가 인기차트 1위에 올랐어요", "1시간 전", read:false
3. id:3, "팔로우한 아티스트가 라이브를 시작했어요", "3시간 전", read:true

---

## 5. 디자인 토큰

### 5.1 색상 — `lib/core/theme/app_colors.dart`

```dart
class AppColors {
  // 배경
  static const Color bgPrimary = Color(0xFF0A0A0F);
  static const Color bgPanel = Color(0xFF16161C);     // queue sheet, profile panel
  static const Color bgPanelTop = Color(0xFF17141F);  // profile panel 그라데이션 top
  static const Color bgPanelBot = Color(0xFF0F0D16);  // profile panel 그라데이션 bot
  static const Color bgToast = Color(0xF21C1C24);     // rgba(28,28,36,0.96)

  // 강조색 (전역 default — 보라)
  static const Color accent = Color(0xFFA78BFA);
  static const Color accentDeep = Color(0xFF7C3AED);
  static const Color accentDeeper = Color(0xFF4A2FA0);
  static const Color accentDark = Color(0xFF2D1B6E);

  // 텍스트 (모두 흰색 + 알파)
  static const Color textPrimary = Colors.white;                 // 100%
  static const Color textSecondary = Color(0xB3FFFFFF);          // 70%
  static const Color textTertiary = Color(0x80FFFFFF);           // 50%
  static const Color textQuaternary = Color(0x59FFFFFF);         // 35%
  static const Color textMuted = Color(0x40FFFFFF);              // 25%
  static const Color textFaint = Color(0x33FFFFFF);              // 20%
  static const Color textGhost = Color(0x26FFFFFF);              // 15%

  // 보더 / 디바이더
  static const Color borderSubtle = Color(0x14FFFFFF);   // rgba(255,255,255,0.08)
  static const Color borderHair = Color(0x0DFFFFFF);     // rgba(255,255,255,0.05)
  static const Color borderFaint = Color(0x0AFFFFFF);    // rgba(255,255,255,0.04)

  // 시맨틱
  static const Color error = Color(0xFFFCA5A5);
  static const Color errorBg = Color(0x1AEF4444);
  static const Color swipeAdd = Color(0x8C50A078);  // 재생목록 추가 스와이프 배경 (녹색)
  static const Color swipeDelete = Color(0xFFE74C3C);

  // 소셜
  static const Color kakaoYellow = Color(0xFFFEE500);
  static const Color kakaoText = Color(0xFF191919);
}
```

### 5.2 폰트 — `lib/core/theme/app_text_styles.dart`

Google Fonts 3종:
- **`Noto Sans KR`** — 본문, UI (w300/400/500/700/900)
- **`Noto Serif KR`** — 제목, 곡명 (w600/700/900)
- **`DM Mono`** — 캡션, 시간, 라벨, 영문 라벨 (w400, letterSpacing 큼)

```dart
class AppTextStyles {
  // Display / Title
  static TextStyle pageTitle = GoogleFonts.notoSerifKr(
    fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white,
    letterSpacing: -0.5,
  );
  static TextStyle sectionTitle = GoogleFonts.notoSerifKr(
    fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white,
    letterSpacing: -0.3,
  );
  static TextStyle songTitleLarge = GoogleFonts.notoSerifKr(
    fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white,
    letterSpacing: -0.5, height: 1.2,
  );
  static TextStyle songTitleMid = GoogleFonts.notoSerifKr(
    fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
    letterSpacing: -0.3, height: 1.3,
  );
  static TextStyle miniPlayerTitle = GoogleFonts.notoSerifKr(
    fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
  );

  // Body
  static TextStyle body = GoogleFonts.notoSansKr(
    fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white,
  );
  static TextStyle bodyLight = GoogleFonts.notoSansKr(
    fontSize: 14, fontWeight: FontWeight.w300, color: AppColors.textSecondary,
  );
  static TextStyle caption = GoogleFonts.notoSansKr(
    fontSize: 12, fontWeight: FontWeight.w300, color: AppColors.textQuaternary,
  );
  static TextStyle artistLabel = GoogleFonts.notoSansKr(
    fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textTertiary,
  );

  // Mono 라벨 (DM Mono — 영문/시간/태그)
  static TextStyle monoLabel = GoogleFonts.dmMono(
    fontSize: 10, fontWeight: FontWeight.w400,
    color: AppColors.textMuted, letterSpacing: 2.5,
  );
  static TextStyle monoTime = GoogleFonts.dmMono(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.textQuaternary, letterSpacing: 0.5,
  );
  static TextStyle monoIndex = GoogleFonts.dmMono(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.textFaint,
  );

  // Nav
  static TextStyle navLabel = GoogleFonts.notoSansKr(
    fontSize: 10, fontWeight: FontWeight.w300, letterSpacing: 0.3,
  );
}
```

### 5.3 간격 / 라운드 — `app_spacing.dart`

```dart
class AppSpacing {
  static const double pagePadH = 20;     // 화면 좌우 패딩
  static const double cardGap = 14;      // 카드간 간격 (Featured)
  static const double sectionGap = 28;   // 섹션 간 마진
  static const double rowGap = 12;       // row 내부 gap

  // Radius
  static const double radiusXs = 8;
  static const double radiusSm = 10;
  static const double radiusMd = 12;
  static const double radiusLg = 14;
  static const double radiusXl = 16;
  static const double radius2xl = 20;
  static const double radius3xl = 24;
}
```

### 5.4 애니메이션 — `app_durations.dart`

| 상황 | duration | curve |
|---|---|---|
| 페이지 마운트 (opacity + translateY) | 500ms | easeOut |
| 미니 플레이어 press scale | 120ms | ease |
| Featured/Compact 카드 press scale | 150ms | ease |
| 곡 row 슬라이드 (스와이프 복귀) | 280ms | cubic(0.4, 0, 0.2, 1) |
| 미니플레이어 progress | 300ms linear |
| Profile/Queue 패널 슬라이드 | 440ms | cubic(0.4, 0, 0.2, 1) |
| Player overlay open/close | 380ms | cubic(0.4, 0, 0.2, 1) |
| 가사 패널 expand/collapse (top) | 440ms | cubic(0.4, 0, 0.2, 1) |
| 가사 활성 라인 (font-size/color) | 300ms | ease |
| 배경색 트랜지션 (곡 변경) | 1200ms | ease |
| 토스트 슬라이드업 | 440ms / opacity 280ms |

```dart
class AppCurves {
  static const Curve standard = Cubic(0.4, 0, 0.2, 1);
}
```

### 5.5 노이즈 텍스처

HTML 의 `body::after` SVG noise (opacity 0.04 → wrapper opacity 0.6 = 약 2.4% 합성). Flutter 에선 `BlendMode.overlay` 로 PNG 노이즈 텍스처를 전역 Stack 최상단에 깔거나, `CustomPainter` 로 흰점 랜덤 흩뿌리기.
권장: `assets/images/noise.png` (256x256 fractal noise tile) 를 `Image.asset(repeat: ImageRepeat.repeat, opacity: AlwaysStoppedAnimation(0.025))` + `IgnorePointer`.

---

## 6. 상태관리 (Provider)

### 6.1 `PlayerProvider` — 전역 음악 상태

HTML 에선 각 페이지가 localStorage 로 동기화하지만, Flutter 에선 **Provider 하나로 전역 관리**.

```dart
class PlayerProvider extends ChangeNotifier {
  // 상태
  List<int> _queue;                 // SONGS index 리스트
  int _queuePos;                    // 현재 큐 위치
  bool _isPlaying;
  double _currentTime;              // 초 (double, 0.5초 단위로 증가)
  int _repeat;                      // 0: off, 1: all, 2: one
  bool _shuffle;
  List<int>? _preShuffleQueue;

  Song get currentSong => SONGS[_queue[_queuePos]];
  double get progress => _currentTime / currentSong.duration;
  int get songIdx => _queue[_queuePos];

  void play(int songIdx);
  void playSongInPlace(int songIdx);  // 현재 곡 다음에 끼워넣고 재생
  void togglePlay();
  void next();
  void prev();                       // 3초 미만이면 처음으로, 이상이면 이전곡
  void seek(double seconds);
  void addToQueue(int songIdx);
  void removeFromQueue(int queuePos);
  void reorderQueue(int from, int to);
  void toggleRepeat();
  void toggleShuffle();

  // Timer — 재생 중 0.5s 마다 _currentTime += 0.5
  // 끝나면 repeat 정책에 따라 next/loop/stop
}
```

**Persistence**: `play`, `togglePlay`, `seek`, queue 변경 시마다 `SharedPreferences` 에 저장.
- 키: `player_songIdx`, `player_isPlaying`("1"/"0"), `player_currentTime`, `player_queue`(JSON 배열)
- 앱 시작 시 `PlayerProvider` 생성자에서 로드.

### 6.2 `SearchProvider`

```dart
class SearchProvider extends ChangeNotifier {
  String _query = '';
  List<String> _recentSearches = ['BTS', 'IU Celebrity', 'NewJeans', 'aespa Savage'];
  String _activeTab = 'genre';  // 'genre' | 'mood'

  List<Song> get results;       // query 로 필터링
  void setQuery(String q);
  void saveSearch(String term);
  void removeRecent(String term);
  void clearRecents();
  void setActiveTab(String t);
}
```

SharedPreferences 키: `recent_searches` (JSON 배열).

### 6.3 `NotificationProvider`

```dart
class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifs;
  bool get hasUnread;
  void markRead(int id);
}
```

---

## 7. 화면별 상세 사양

### 7.1 Login — `LoginPage`

**배경**: `RadialGradient(center: Alignment(0, -1.2), radius: 1.0, colors: [#4a2fa0cc, #2d1b6e55, #0d0a18, #060608])`

**구성 (위에서 아래)**:
1. 상단 80px 패딩
2. **로고 마크**: 64×64, radius 20, `LinearGradient(135deg, #1a0a2e → #4a2fa0 → #7c3aed)`, border `rgba(167,139,250,0.25)`, shadow `0 16px 48px #7c3aed33`. 내부 vinyl: 28×28 원형 그라데이션, 7×7 중앙 dot.
3. 타이틀 `._.` — Noto Serif KR 26/900, 흰색
4. 서브 `MUSIC FOR FANS` — DM Mono 10, letterSpacing 3, 흰색 25%
5. 48px 갭
6. **로그인** 타이틀 (Serif 20/700)
7. **이메일 InputField**: label "이메일", placeholder "hello@example.com"
8. **비밀번호 InputField**: label "비밀번호", type:password, 오른쪽 EyeIcon 토글
9. 에러 메시지 (조건부)
10. "비밀번호 찾기" — 우측 정렬, DM Mono 11, accent60%
11. **로그인 버튼**: 풀폭, h54, radius 16, `LinearGradient(135deg, #4a2fa0, #7c3aed)`, shadow `0 8px 32px #7c3aed66`. 로딩 중엔 회색+spinner.
12. OR 디바이더 (양쪽 hairline + 가운데 "OR" Mono)
13. **카카오 버튼**: h50, radius 14, bg `#FEE500`, text `#191919`, kakao icon
14. **Apple 버튼**: h50, radius 14, bg `rgba(255,255,255,0.06)`, border `rgba(255,255,255,0.1)`, apple SVG icon
15. "아직 계정이 없으신가요? **가입하기**" (가입하기는 accent색)

**InputField 위젯**:
- label (Mono 10, letterSpacing 2) — focused 시 accent 색
- 입력영역: border 1px, radius 14, focused 시 border `#a78bfa44` + bg `rgba(167,139,250,0.05)`
- transition 250ms ease
- focused 시 하단 1px 그라데이션 라인 (`transparent → accent → transparent`)
- TextField padding `15px 18px`, fontSize 15 w300

**동작**:
- 로그인 버튼 탭 → 1.2초 spinner → `Navigator.pushReplacement('/home')`
- 이메일은 SharedPreferences `login_email` 로 저장/복원
- 빈 입력 시 에러 표시

### 7.2 Home — `HomePage`

**최상위 구조** (Stack):
```
Stack
├── Container (배경 #0a0a0f)
├── 앰비언트 글로우 (현재 곡 coverAccent, 280×280, blur 60, top:-60 left:30%)
├── Column
│   ├── Expanded (스크롤 영역)
│   │   ├── Header
│   │   ├── SectionHeader "추천 트랙" + 전체보기
│   │   ├── 가로스크롤 FeaturedCard ×4
│   │   ├── 칩 필터 row (가로스크롤)
│   │   ├── SectionHeader "최근 재생"
│   │   ├── SongRow ×5
│   │   ├── SectionHeader "좋아하는 아티스트"
│   │   ├── 가로스크롤 ArtistCard ×5
│   │   ├── SectionHeader "당신을 위한 추천"
│   │   ├── 가로스크롤 CompactCard ×10 (역순)
│   │   └── SizedBox(height: 180)
│   └── 하단 영역 (MiniPlayer + BottomNav)
├── ProfilePanel (visible 시 슬라이드)
└── PlayerOverlay (visible 시 슬라이드업)
```

**Header**:
- 좌측: 인사말 ("좋은 아침이에요" 등 시간대별, DM Mono 10 letterSpacing 2.5, 흰색 25%) + "오늘의 음악" (Serif 24/900)
- 우측: 프로필 아이콘 버튼 (40×40) — 미확인 알림 있으면 우상단 7×7 보라 dot (border #0a0a0f 1.5px)

**시간대별 인사말** — `core/utils/greeting.dart`:
```dart
String getGreeting() {
  final h = DateTime.now().hour;
  final map = {
    'dawn':    ["새벽의 음악은 조용히", "잠 못 드는 밤엔 음악과", "새벽 감성 충전 중", "고요한 새벽, 귀를 열어요"],
    'morning': ["좋은 아침이에요", "오늘도 음악과 함께", "아침을 깨우는 플레이리스트", "상쾌한 하루의 시작"],
    'noon':    ["점심 시간, 잠깐 쉬어요", "낮의 리듬을 찾아서", "오늘 점심 BGM은?", "한숨 돌리는 시간"],
    'afternoon': ["오후의 여유를 즐겨요", "집중력이 필요한 시간", "오후의 감성 한 곡", "슬럼프엔 음악이지"],
    'evening': ["오늘 하루 수고했어요", "퇴근길 귀를 채워요", "저녁 바람과 함께", "하루를 마무리하며"],
    'night':   ["밤의 플레이리스트", "오늘 밤의 선택", "고독한 밤엔 음악이지", "밤이 깊어질수록"],
  };
  String key;
  if (h >= 4 && h < 7) key = 'dawn';
  else if (h >= 7 && h < 12) key = 'morning';
  else if (h >= 12 && h < 14) key = 'noon';
  else if (h >= 14 && h < 18) key = 'afternoon';
  else if (h >= 18 && h < 22) key = 'evening';
  else key = 'night';
  final list = map[key]!;
  return list[Random().nextInt(list.length)];
}
```
앱이 다시 마운트될 때 한 번만 뽑고 상태로 보관.

**FeaturedCard** (240px wide):
- radius 20, padding 18, gradient `linear(145deg, colors[1], colors[2])`, border `${accent}18`, shadow `0 8px 32px ${coverAccent}33`
- 내부: LargeCover 204×204 (vinyl 효과) + title (Serif 16/700) + subtitle (Sans 12/300 50% — "아티스트 · 앨범")
- 탭 시 scale 0.96 (150ms), `PlayerProvider.play(songIdx)`

**LargeCover** (vinyl 효과 재현):
```
Container (gradient: coverGradient, radius 20)
└── Center
    └── 44%×44% circle (radial gradient 어두운중심 → coverAccent55, border accent33)
        └── 11%×11% 중앙 black dot (border accent55)
└── 오버레이: repeating-linear-gradient(0deg, transparent 32px, accent07 1px)  
```
Flutter 에선 `Stack` + `Container.decoration` + `CustomPaint` 줄무늬.

**칩 필터** — 가로스크롤, 6개:
- 첫번째 ("전체"): gradient `linear(135deg, #4a2fa0, #7c3aed)`, shadow `0 4px 16px rgba(124,58,237,0.35)`, 흰색 텍스트 500
- 나머지: bg `rgba(255,255,255,0.06)`, border `rgba(255,255,255,0.08)`, 텍스트 흰색 45% / 300
- padding `7px 16px`, radius 20, fontSize 12

**SongRow** (최근 재생):
- 좌측: index (20px 너비, Mono 11, 흰색 20%) + MiniCover 48×48 + 곡명/아티스트 + 시간(Mono 11)
- padding `10px 20px`
- press 시 bg `rgba(255,255,255,0.04)`
- **오른쪽 스와이프 (max 140px)**: 배경에 녹색 그라데이션 `linear(90deg, rgba(80,160,120,0.55), transparent)` + "＋ 재생목록에 추가"
- 70px 이상 스와이프 → `addToQueue(idx)` + 토스트 표시 + 원위치 (transition 280ms)
- 스와이프 직후엔 탭 이벤트 무시 (400ms)

**ArtistCard** (70×70 원형):
- `RadialGradient(center: Alignment(-0.2, -0.3), colors: [${color}88, ${color}22])`, border `1.5px ${color}44`, shadow `0 4px 16px ${color}33`
- 내부: 첫 글자 (Serif 22/900)
- 하단 label (Sans 11 흰색60%) — maxWidth 70, ellipsis

**CompactCard** (130×130):
- MiniCover 130×130 radius 16 + 하단 title (Sans 13/500) + artist (Sans 11/300 35%)

**SectionHeader**:
- 좌: 타이틀 (Serif 17/700)
- 우: "전체보기 >" 버튼 (Mono 10, letterSpacing 1.5, 흰색30%) — 누르면 아무것도 안함 (placeholder)

**MiniPlayer** (하단 고정):
- margin `0 12px 8px`, radius 16
- bg `linear(135deg, currentSong.colors[1]cc, currentSong.colors[2]99)`, border `1px ${accent}22`
- BackdropFilter blur 20
- padding `10px 12px 12px`
- 구성: MiniCover 42 + 타이틀(Serif 14/700)+아티스트(11/300 50%) + Prev버튼(32) + Play/Pause버튼(36, bg `rgba(255,255,255,0.12)`) + Next버튼(32)
- 하단 2px progress 바: bg `rgba(255,255,255,0.08)`, 진행 `${accent}`, width 트랜지션 300ms linear
- 탭 → Player overlay 슬라이드업

**BottomNav** (하단):
- height 자연스럽게, padding `8px 0 24px`, top border `1px rgba(255,255,255,0.04)`
- 4탭: 홈/검색/보관함/프로필
- 아이콘 22×22, label 10px (active 500, inactive 300)
- active 색: `#a78bfa`, inactive: `rgba(255,255,255,0.3)`
- 검색만 라우팅 (`/search`), 나머진 setState

**ProfilePanel** (우측 슬라이드):
- 92% width, 우측에서 슬라이드, transform `translateX(0 ↔ 100%)`, 440ms
- 좌측 dim 오버레이 `rgba(0,0,0,0.5)`, 탭하면 닫힘
- 우로 스와이프 60px+ → 닫힘
- bg `linear(160deg, #17141f, #0f0d16)`, borderLeft `1px rgba(255,255,255,0.07)`
- 내부:
  1. 프로필 (52×52 아바타 + 이름 "뮤직 팬" + 핸들 "@musicfan_kr" + "프로필 보기 >" 링크)
  2. 디바이더
  3. 설정 row (36×36 톱니바퀴 + "설정")
  4. 디바이더
  5. 알림 카드 (margin `12px 16px`, radius 16, bg `rgba(255,255,255,0.03)`, border `rgba(255,255,255,0.06)`)
     - 헤더: 종 아이콘 + "알림" (Mono 10) / 우측 "전체 보기"
     - 알림 row ×3 (읽음 여부 dot, 텍스트, 시간, 읽음 처리 체크 버튼)
     - 빈 상태: "새 알림이 없어요"

**Player Overlay**:
- Stack 위에 슬라이드업으로 `PlayerPage` 표시
- transform `translateY(100% → 0)` 380ms cubic(0.4,0,0.2,1)
- 닫기는 PlayerPage 내부에서 `Navigator.pop` 또는 콜백
- 드래그다운 120px+ → 닫힘 (드래그 중 transform 따라감)

### 7.3 Search — `SearchPage`

기본 구조는 Home 과 유사 (배경, 노이즈, 미니플레이어, 네비, 프로필패널, 플레이어 오버레이 모두 동일).

**Header**:
- 타이틀 "검색" (Serif 24/900) + 우측 프로필 아이콘
- 검색 입력: h48, radius 14, bg `rgba(255,255,255,0.05)` / focused `rgba(167,139,250,0.07)`, border 1px (focused 시 accent30%)
- 좌측 search 아이콘, placeholder "아티스트, 곡, 앨범 검색"
- 우측 x 버튼 (입력 있을 때만, 22×22 원형 bg `rgba(255,255,255,0.1)`)
- focus 시 하단 1px 그라데이션 라인

**검색 미입력 상태**:
1. **최근 검색** 섹션 (`recent_searches` SharedPreferences 키):
   - 헤더 "최근 검색" + "전체 삭제"
   - row: 34×34 시계 아이콘 박스 + 검색어 (Sans 14/300 60%) + x 버튼
   - fadeUp 애니메이션 (각 row 30ms delay)
2. **탭 토글** (장르/무드):
   - 컨테이너 bg `rgba(255,255,255,0.04)`, border 1px, radius 12, padding 3
   - active 탭: gradient `linear(135deg, #4a2fa0, #7c3aed)`, shadow
3. **GenreGrid** (2 컬럼):
   - 8개 카드, gap 10
   - 각 카드: radius 16, bg `Genre.bgGradient`, border `${color}22`, padding `18px 16px`, minHeight 70
   - 우상단 장식 원 ×2 (72×72 top:-16 right:-16 bg `${color}33` + 40×40 top:4 right:8 `${color}22`)
   - 라벨: Serif 15/700 좌하단 정렬
4. **MoodRow** (세로 리스트, 4개):
   - 44×44 아이콘 박스 (radius 14, bg `rgba(167,139,250,0.08)`, border `rgba(167,139,250,0.12)`, 글리프 18px)
   - 라벨 (Sans 14/500) + "{songs} TRACKS" (Mono 10/25%)
   - 우측 chevron

**검색 입력 상태**:
- 결과 0건: "NO RESULTS" (Mono 11) + `"$query"` (Serif 18 40%) + "다른 검색어를 시도해 보세요"
- 결과: 헤더 "결과 N곡" + `SongResultRow` (Home 의 SongRow 와 동일하되 index 없음)
- Enter 키 → `saveSearch(query)` (`recent_searches` 에 저장)

**필터 로직**: title / artist / album / tags 중 하나라도 query.toLowerCase() 포함하면 hit.

### 7.4 Player — `PlayerPage`

가장 복잡한 화면. **오버레이로 표시되며**, 컨테이너 자체가 슬라이드업.

**배경**: 현재 곡 기반 RadialGradient
```dart
RadialGradient(
  center: Alignment(0, -1.1),
  radius: 1.3,
  colors: [
    song.colors[2].withOpacity(0.8),
    song.colors[1].withOpacity(0.53),
    song.colors[0],
    Color(0xFF060608),
  ],
  stops: [0, 0.35, 0.7, 1.0],
)
```
곡 변경 시 1200ms ease 로 트랜지션 (`AnimatedContainer`).

**상단 바** (paddingTop 56):
- 좌: 아래 화살표 (V) 버튼 — 닫기
- 가운데: "NOW PLAYING" (Mono 11, letterSpacing 2, 35%)
- 우: `⋯` (수평 점3개) 버튼

**앨범 커버** (정사각, paddingH 28):
- aspectRatio 1:1, radius 24
- bg `coverGradient`
- 내부 vinyl:
  - 42%×42% 원형 radial gradient (`rgba(0,0,0,0.9)` 30% → `${coverAccent}44` 70% → `rgba(0,0,0,0.6)` 100%), border `1px ${accent}33`, shadow `0 0 40px ${coverAccent}44`
  - 재생 중이면 8초 1회전 무한 (`RotationTransition`)
  - 정중앙 10%×10% 검정 dot, border `2px ${accent}66`
- 오버레이: 줄무늬 (40px 간격, accent08 1px) — `CustomPaint`
- 좌하단 워터마크: 아티스트 첫글자 (Serif 80/900, `${accent}18`, letterSpacing -4)
- shadow: `0 32px 80px -8px ${coverAccent}55, 0 8px 32px rgba(0,0,0,0.8)`

**가사 패널** (앨범커버와 곡 정보 사이 영역, 좌우 28px):
- **두 가지 상태**: collapsed (h44, 한 줄만 표시) / expanded (앨범커버 위치까지 확장, 스크롤 가능)
- bg `${song.colors[1]}cc`, border `1px ${accent}22`, radius 16, BackdropFilter blur 24
- collapsed: 좌측 ♪ 또는 📣 아이콘 + 현재 가사 한 줄 (lyricsColor, 13 w300, ellipsis)
- expanded:
  - 상단 36×3 드래그 핸들 (탭 시 collapse)
  - 가사 리스트: 각 줄 padding `9px 0`
  - active 라인: fontSize 15, w600, lyricsColor
  - 비활성: fontSize 13, w300, `${lyricsColor}44`
  - transition 300ms ease (fontSize, color)
  - 가사 줄 탭 → seek 해당 시간
- 위로 스와이프 → expand (only when collapsed)
- 아래로 스와이프 60px+ → collapse (스크롤 영역 내 스와이프는 무시)
- 펜챈트 모드 시: LYRICS → FANCHANT 데이터 교체

**곡 정보** (가사패널 아래, padding `0 24px 36px`):
- 좌: 곡명 (Serif 22/900) + "아티스트 · 앨범" (Sans 13/300 50%)
- 우: 하트 버튼 44×44 (liked 시 `${accent}` filled, else `rgba(255,255,255,0.5)` outline)

**ProgressBar**:
- 높이 36 터치영역, 내부 3px 바
- bg `rgba(255,255,255,0.12)`, 진행 `linear(90deg, ${accent}88, ${accent})`
- thumb: 10×10 흰원 + shadow `0 0 12px ${accent}88`, 드래그 중 16×16
- 드래그/탭으로 seek
- 시간 라벨: 좌 currentTime / 우 duration (Mono 11, 35%, marginTop -4)

**메인 컨트롤** (Row, justifyContent: space-between):
- Shuffle (20) — shuffle 시 accent색
- Prev (24)
- **Play/Pause** 72×72 원형, gradient `linear(135deg, colors[2], coverAccent)`, border `1.5px ${accent}44`, shadow `0 8px 32px ${coverAccent}55`
- Next (24)
- Repeat (20) — repeat 1/2 시 accent색, repeat 2 시 가운데 "1" 텍스트

모든 아이콘버튼은 press 시 scale 0.88 (120ms).

**Fanchant + Queue row**:
- 좌: 마이크 아이콘 버튼 (활성시 accent색 + filled)
- 우: 큐 아이콘 버튼 (햄버거 3줄, 40%)

**QueueSheet** (큐 버튼 → 슬라이드업):
- top: 앨범커버 중간지점 (mainContainer 기준 좌표 계산)
- bottom: 0
- bg `#16161c`, borderTopRadius 20, border `1px rgba(255,255,255,0.07)`
- transform `translateY(100% ↔ 0)` 440ms
- 드래그핸들 영역에서만 아래스와이프 60px+ → 닫힘
- 헤더: "QUEUE — N TRACKS" (Mono 11) + 우측 Shuffle/Repeat 토글 버튼
- 리스트 항목 (각 64px 높이):
  - MiniCover 44 + 곡명(w400 또는 현재곡 w600) + 아티스트·시간 + 우측 드래그핸들 (3줄)
  - 현재 재생곡: bg `rgba(28,28,36,1)` + overlay `rgba(255,255,255,0.06)`
  - **세로 드래그**: 핸들 길게눌러 위/아래 드래그 → 항목 재배치 (64px 단위)
  - 드래그 중: scale 1.02, shadow `0 8px 24px rgba(0,0,0,0.5)`
  - **좌측 스와이프 100px+**: 삭제 (단, 큐에 곡 2개 이상일때만). 슬라이드아웃 220ms 후 제거. 빨간 배경 `linear(90deg, transparent, #c0392b 60%, #e74c3c)` + "삭제" 라벨

**셔플 토글**:
- ON: 현재 곡 제외 나머지를 셔플 → `[현재곡, ...셔플된나머지]`, queuePos = 0. `preShuffleQueue` 에 원래 큐 백업.
- OFF: 백업된 큐 복원, 현재 곡의 새 위치로 queuePos 갱신.

**Repeat 사이클**: 0(off) → 1(all) → 2(one) → 0...
- 곡 끝났을 때:
  - 2: 처음으로 (loop)
  - 1: 다음곡, 큐 끝이면 0번으로
  - 0: 다음곡, 큐 끝이면 정지

**Prev 동작**: `currentTime > 3` 이면 처음으로, 아니면 이전 곡.

**드래그 다운으로 닫기**:
- Player 컨테이너 자체를 위에서 아래로 스와이프하면 dy만큼 translateY
- 단, `data-no-player-swipe` 영역 (가사 패널, 큐 시트) 에서 시작한 스와이프는 무시
- 120px+ 떨어뜨리면 닫힘 (`Navigator.pop()`)

---

## 8. 공통 위젯 디테일

### MiniCover (size, radius 지정)
```
Container(
  size: size×size, radius
  decoration: LinearGradient(135deg, coverGradient)
  child: Stack [
    Center: 44%×44% radial circle (dark→coverAccent44),
    Center: 12%×12% black dot
  ]
)
```

### BottomNav
4 탭 모두 동일한 구조. 라우팅 처리:
- 홈: 현재 페이지면 noop, 다른 페이지면 pop until home
- 검색: push Search
- 보관함/프로필: 미구현 (탭 인디케이터만)

### Toast
하단 미니플레이어 **뒤에서** 슬라이드업되는 형태:
- `Stack` 의 z-order 로 미니플레이어 아래 배치
- bg `rgba(28,28,36,0.96)` + blur 20, radius 14, padding `12px 16px 22px` (아래 22 → 미니플레이어 뒤에 숨겨질 영역)
- 메시지: "재생목록에 추가됨 · {title} — {artist}"
- 2400ms 자동 닫힘

---

## 9. localStorage → SharedPreferences 매핑

| HTML 키 | Flutter 키 | 타입 | 용도 |
|---|---|---|---|
| `player_songIdx` | `player_song_idx` | int | 현재 곡 SONGS index |
| `player_isPlaying` | `player_is_playing` | bool | 재생 여부 |
| `player_currentTime` | `player_current_time` | double | 재생 위치(초) |
| `player_queue` | `player_queue` | String (JSON) | 큐 (List<int>) |
| `login_email` | `login_email` | String | 마지막 로그인 이메일 |
| `recent_searches` | `recent_searches` | String (JSON) | 최근 검색어 |

---

## 10. 구현 순서

1. **프로젝트 셋업** — `flutter create`, `pubspec.yaml`, Google Fonts, 폴더 트리
2. **디자인 토큰** — colors / text styles / spacing / curves
3. **모델 + Mock 데이터** — Song, Artist, Genre, Mood, LyricLine, AppNotification + 상수 파일
4. **Provider** — PlayerProvider (SharedPreferences 통합), SearchProvider, NotificationProvider
5. **공통 위젯** — MiniCover, LargeCover, MiniPlayerBar, BottomNavBar, ProfilePanel, NoiseOverlay, 아이콘 위젯들
6. **Login** — 가장 단순, 토큰/위젯 검증용
7. **Home** — SectionHeader, FeaturedCard, SongRow (스와이프), ArtistCard, CompactCard, 칩필터, 인사말
8. **Search** — 입력/결과/장르그리드/무드리스트/최근검색
9. **Player** — AlbumCover (회전 vinyl), LyricsPanel (expand/collapse + 자동 스크롤), ProgressBar, QueueSheet (재배치 + 스와이프 삭제)
10. **오버레이 통합** — Home/Search → Player 슬라이드업 + 드래그다운 닫기
11. **노이즈 오버레이** + 마이크로 폴리시 (애니메이션 듀레이션 / press 피드백)

---

## 11. 주의사항

- **`Player.html` 에는 iframe 통신 (`postMessage`) 로직** 이 있는데, Flutter 에선 Provider 하나로 통합되므로 **무시**.
- HTML 의 `requestAnimationFrame` 트릭은 Flutter 에선 불필요. `setState` 또는 `AnimationController` 로 대체.
- HTML 의 `BackdropFilter blur` 효과는 Flutter `BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20))` 로 그대로 재현 가능.
- 모든 색상의 `rgba(R,G,B,A)` 는 `Color.fromRGBO(R,G,B,A)` 로 변환.
- HTML 의 `linear-gradient(135deg, A, B, C)` 는 `LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [A,B,C])` (정확히 135도는 아니지만 시각적으로 동일).
- 곡 변경 시 모든 배경/그라데이션/accent 색이 1200ms 동안 부드럽게 전환 — `AnimatedContainer` 활용.
- **HTML 의 SVG 아이콘은 모두 `flutter_svg` 의 인라인 SvgPicture.string 또는 별도 위젯으로 구현**. 아이콘 목록:
  - HomeIcon, SearchIcon, LibraryIcon, ProfileIcon (네비)
  - PlayIcon, PauseIcon, PrevIcon, NextIcon, PrevSmIcon, NextSmIcon
  - ChevronRight, ChevronDown, BackIcon, MoreIcon, CloseIcon
  - ShuffleIcon, RepeatIcon (one variant 포함), HeartIcon, QueueIcon
  - FanchantIcon, EyeIcon (open/closed)
  - KakaoIcon, AppleIcon
  - ClockIcon, BellIcon, SettingsIcon
  - 모든 stroke / fill / strokeWidth 는 HTML SVG 그대로 옮기기

---

이대로 따라 만들면 HTML 프로토타입과 픽셀 단위로 동일한 Flutter 앱이 완성됩니다.
