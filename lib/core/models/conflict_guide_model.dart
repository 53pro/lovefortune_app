// lib/core/models/conflict_guide_model.dart

class ConflictGuideModel {
  final String analysisForMe;
  final String analysisForPartner;
  final String solutionProposal;
  final String dialogueExample;

  ConflictGuideModel({
    required this.analysisForMe,
    required this.analysisForPartner,
    required this.solutionProposal,
    required this.dialogueExample,
  });

  factory ConflictGuideModel.fromJson(Map<String, dynamic> json) {
    // Helper 함수를 사용하여 어떤 타입의 값이 오더라도 안전하게 문자열로 변환합니다.
    String safeString(dynamic value, String defaultValue) {
      if (value == null) return defaultValue;
      if (value is String) return value;
      // Map이나 다른 타입을 의미 있는 문자열로 변환합니다.
      return value.toString();
    }

    return ConflictGuideModel(
      analysisForMe: safeString(json['analysis_for_me'], '나의 성향 분석을 불러오는 데 실패했습니다.'),
      analysisForPartner: safeString(json['analysis_for_partner'], '상대방의 성향 분석을 불러오는 데 실패했습니다.'),
      solutionProposal: safeString(json['solution_proposal'], '관계 솔루션을 불러오는 데 실패했습니다.'),
      dialogueExample: safeString(json['dialogue_example'], '대화 예시를 불러오는 데 실패했습니다.'),
    );
  }
}
