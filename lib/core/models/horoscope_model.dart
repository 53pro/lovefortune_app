// --- lib/core/models/horoscope_model.dart (수정) ---
// 이 파일에 toJson 메서드를 추가하여, 객체를 저장 가능한 형태로 변환합니다.
class HoroscopeModel {
  final int compatibilityScore;
  final String summary;
  final String positiveAdvice;
  final String cautionAdvice;
  final String recommendedDate;

  HoroscopeModel({
    required this.compatibilityScore,
    required this.summary,
    required this.positiveAdvice,
    required this.cautionAdvice,
    required this.recommendedDate,
  });

  factory HoroscopeModel.fromJson(Map<String, dynamic> json) {
    return HoroscopeModel(
      compatibilityScore: json['compatibility_score'] as int,
      summary: json['summary'] as String,
      positiveAdvice: json['positive_advice'] as String,
      cautionAdvice: json['caution_advice'] as String,
      recommendedDate: json['recommended_date'] as String,
    );
  }

  // 객체를 Map<String, dynamic> 형태로 변환하는 toJson 메서드 (추가)
  Map<String, dynamic> toJson() {
    return {
      'compatibility_score': compatibilityScore,
      'summary': summary,
      'positive_advice': positiveAdvice,
      'caution_advice': cautionAdvice,
      'recommended_date': recommendedDate,
    };
  }
}