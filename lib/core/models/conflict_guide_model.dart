// --- lib/core/models/conflict_guide_model.dart (신규 생성) ---
// AI가 생성할 구조화된 갈등 해결 가이드의 데이터 구조를 정의합니다.
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
    return ConflictGuideModel(
      analysisForMe: json['analysis_for_me'] as String? ?? '분석 중...',
      analysisForPartner: json['analysis_for_partner'] as String? ?? '분석 중...',
      solutionProposal: json['solution_proposal'] as String? ?? '분석 중...',
      dialogueExample: json['dialogue_example'] as String? ?? '분석 중...',
    );
  }
}