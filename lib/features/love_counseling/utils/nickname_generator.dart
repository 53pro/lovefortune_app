import 'dart:math';

class NicknameGenerator {
  static const List<String> _adjectives = [
    '수줍은', '상냥한', '달콤한', '솔직한', '듬직한', '영리한', '따뜻한', 
    '신비로운', '진지한', '발랄한', '조용한', '낭만적인', '차분한', '지혜로운',
    '용감한', '행복한', '귀여운', '온화한', '명랑한', '성실한', '신중한'
  ];

  static const List<String> _nouns = [
    '고양이', '호랑이', '토끼', '강아지', '사슴', '돌고래', '여우', 
    '민들레', '해바라기', '별빛', '은하수', '바람', '구름', '바다',
    '사자', '앵무새', '원숭이', '다람쥐', '팬더', '펭귄', '코알라'
  ];

  /// Generates a random nickname (e.g., "수줍은 고양이 432")
  static String generate() {
    final random = Random();
    final adjective = _adjectives[random.nextInt(_adjectives.length)];
    final noun = _nouns[random.nextInt(_nouns.length)];
    final suffix = random.nextInt(1000); // 0 ~ 999
    
    return '$adjective $noun $suffix';
  }
}
