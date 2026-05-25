// lib/core/models/self_discovery_model.dart

class SelfDiscoveryModel {
  final String dailyTheme;
  final String detailedAnalysis;
  final String growthTip;
  final List<String> actionableSteps;
  final String recommendedHabit;
  final String reflectiveQuestion;

  SelfDiscoveryModel({
    required this.dailyTheme,
    required this.detailedAnalysis,
    required this.growthTip,
    required this.actionableSteps,
    required this.recommendedHabit,
    required this.reflectiveQuestion,
  });

  factory SelfDiscoveryModel.fromJson(Map<String, dynamic> json) {
    return SelfDiscoveryModel(
      dailyTheme: json['daily_theme'] as String? ?? '테마 없음',
      detailedAnalysis: json['detailed_analysis'] as String? ?? '분석 내용이 없습니다.',
      growthTip: json['growth_tip'] as String? ?? '성장 팁 없음',
      actionableSteps: (json['actionable_steps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      recommendedHabit: json['recommended_habit'] as String? ?? '추천 습관이 없습니다.',
      reflectiveQuestion: json['reflective_question'] as String? ?? '성찰 질문 없음',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_theme': dailyTheme,
      'detailed_analysis': detailedAnalysis,
      'growth_tip': growthTip,
      'actionable_steps': actionableSteps,
      'recommended_habit': recommendedHabit,
      'reflective_question': reflectiveQuestion,
    };
  }
}
