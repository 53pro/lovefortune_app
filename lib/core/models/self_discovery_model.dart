// --- lib/core/models/self_discovery_model.dart (신규 생성) ---
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
      dailyTheme: json['daily_theme'] as String,
      growthTip: json['growth_tip'] as String,
      reflectiveQuestion: json['reflective_question'] as String,
    );
  }
}