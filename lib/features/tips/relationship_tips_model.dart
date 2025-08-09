// --- lib/features/tips/relationship_tips_model.dart ---
class RelationshipTipsModel {
  final String personalityAnalysis;
  final String weeklyQuestion;
  // TODO: 더 복잡한 데이터 구조 추가 가능

  RelationshipTipsModel({
    required this.personalityAnalysis,
    required this.weeklyQuestion,
  });

  factory RelationshipTipsModel.fromJson(Map<String, dynamic> json) {
    return RelationshipTipsModel(
      personalityAnalysis: json['personality_analysis'],
      weeklyQuestion: json['weekly_question'],
    );
  }
}


