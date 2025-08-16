// --- lib/core/models/personality_report_model.dart (신규 생성) ---
// 성향 분석 리포트의 데이터 구조를 정의합니다.
class PersonalityReportModel {
  final String myPersonalityTitle;
  final String myPersonalityDescription;
  final String partnerPersonalityTitle;
  final String partnerPersonalityDescription;
  final String relationshipSynergy;
  final String relationshipCaution;

  PersonalityReportModel({
    required this.myPersonalityTitle,
    required this.myPersonalityDescription,
    required this.partnerPersonalityTitle,
    required this.partnerPersonalityDescription,
    required this.relationshipSynergy,
    required this.relationshipCaution,
  });

  factory PersonalityReportModel.fromJson(Map<String, dynamic> json) {
    return PersonalityReportModel(
      myPersonalityTitle: json['my_personality_title'] as String? ?? '분석 중...',
      myPersonalityDescription: json['my_personality_description'] as String? ?? '자세한 내용을 불러오고 있습니다.',
      partnerPersonalityTitle: json['partner_personality_title'] as String? ?? '분석 중...',
      partnerPersonalityDescription: json['partner_personality_description'] as String? ?? '자세한 내용을 불러오고 있습니다.',
      relationshipSynergy: json['relationship_synergy'] as String? ?? '두 분의 시너지에 대해 알아보고 있습니다.',
      relationshipCaution: json['relationship_caution'] as String? ?? '두 분의 관계에서 주의할 점을 알아보고 있습니다.',
    );
  }
}