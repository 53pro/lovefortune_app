// 이 파일은 AI로부터 받은 운세 데이터의 구조를 정의하는 순수한 데이터 클래스(Model)입니다.

class HoroscopeModel {
  // AI 프롬프트에서 요청한 JSON의 키값과 일치하는 변수들입니다.
  final int compatibilityScore;
  final String summary;
  final String positiveAdvice;
  final String cautionAdvice;
  final String recommendedDate;

  // 생성자
  HoroscopeModel({
    required this.compatibilityScore,
    required this.summary,
    required this.positiveAdvice,
    required this.cautionAdvice,
    required this.recommendedDate,
  });

  // JSON(Map<String, dynamic> 형태) 데이터로부터 HoroscopeModel 객체를 만드는
  // 팩토리 생성자(factory constructor)입니다.
  // 이 메서드는 AI 서비스가 보낸 JSON 응답을 Dart 객체로 변환하는 데 사용됩니다.
  factory HoroscopeModel.fromJson(Map<String, dynamic> json) {
    return HoroscopeModel(
      // json['key']의 'key'는 AI 프롬프트에서 정의한 JSON 키와 정확히 일치해야 합니다.
      compatibilityScore: json['compatibility_score'] as int,
      summary: json['summary'] as String,
      positiveAdvice: json['positive_advice'] as String,
      cautionAdvice: json['caution_advice'] as String,
      recommendedDate: json['recommended_date'] as String,
    );
  }
}
