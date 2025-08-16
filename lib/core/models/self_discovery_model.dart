// lib/core/models/self_discovery_model.dart

class SelfDiscoveryModel {
  final String dailyTheme;
  final String growthTip;
  final String reflectiveQuestion;

  SelfDiscoveryModel({
    required this.dailyTheme,
    required this.growthTip,
    required this.reflectiveQuestion,
  });

  factory SelfDiscoveryModel.fromJson(Map<String, dynamic> json) {
    return SelfDiscoveryModel(
      dailyTheme: json['daily_theme'] as String? ?? '테마 없음',
      growthTip: json['growth_tip'] as String? ?? '성장 팁 없음',
      reflectiveQuestion: json['reflective_question'] as String? ?? '성찰 질문 없음',
    );
  }

  // 객체를 Map<String, dynamic> 형태로 변환하는 toJson 메서드 (추가)
  Map<String, dynamic> toJson() {
    return {
      'daily_theme': dailyTheme,
      'growth_tip': growthTip,
      'reflective_question': reflectiveQuestion,
    };
  }
}
