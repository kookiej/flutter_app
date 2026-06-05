import 'dart:math';

String getGreeting() {
  final h = DateTime.now().hour;
  final map = {
    'dawn': ["새벽의 음악은 조용히", "잠 못 드는 밤엔 음악과", "새벽 감성 충전 중", "고요한 새벽, 귀를 열어요"],
    'morning': ["좋은 아침이에요", "오늘도 음악과 함께", "아침을 깨우는 플레이리스트", "상쾌한 하루의 시작"],
    'noon': ["점심 시간, 잠깐 쉬어요", "낮의 리듬을 찾아서", "오늘 점심 BGM은?", "한숨 돌리는 시간"],
    'afternoon': ["오후의 여유를 즐겨요", "집중력이 필요한 시간", "오후의 감성 한 곡", "슬럼프엔 음악이지"],
    'evening': ["오늘 하루 수고했어요", "퇴근길 귀를 채워요", "저녁 바람과 함께", "하루를 마무리하며"],
    'night': ["밤의 플레이리스트", "오늘 밤의 선택", "고독한 밤엔 음악이지", "밤이 깊어질수록"],
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
