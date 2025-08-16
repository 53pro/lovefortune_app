// lib/core/models/personality_report_model.dart

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

  // 객체를 Map<String, dynamic> 형태로 변환하는 toJson 메서드 (추가)
  // 이 함수는 데이터를 휴대폰에 저장하기 위해 필요합니다.
  Map<String, dynamic> toJson() {
    return {
      'my_personality_title': myPersonalityTitle,
      'my_personality_description': myPersonalityDescription,
      'partner_personality_title': partnerPersonalityTitle,
      'partner_personality_description': partnerPersonalityDescription,
      'relationship_synergy': relationshipSynergy,
      'relationship_caution': relationshipCaution,
    };
  }
}
