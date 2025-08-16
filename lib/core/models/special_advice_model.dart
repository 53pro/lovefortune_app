// lib/core/models/special_advice_model.dart

class SpecialAdviceModel {
  final String synergyPoint;
  final String conflictWarning;
  final String weekendForecast;
  final String monthlyLuckyDay;

  SpecialAdviceModel({
    required this.synergyPoint,
    required this.conflictWarning,
    required this.weekendForecast,
    required this.monthlyLuckyDay,
  });

  factory SpecialAdviceModel.fromJson(Map<String, dynamic> json) {
    // Helper 함수를 사용하여 어떤 타입의 값이 오더라도 안전하게 문자열로 변환합니다.
    String _safeString(dynamic value, String defaultValue) {
      if (value == null) return defaultValue;
      if (value is String) return value;
      return value.toString(); // Map이나 다른 타입을 문자열로 변환
    }

    return SpecialAdviceModel(
      synergyPoint: _safeString(json['synergy_point'], '오늘은 함께 조용한 시간을 보내며 서로에게 집중해보세요.'),
      conflictWarning: _safeString(json['conflict_warning'], '오늘은 특별히 주의할 점이 없네요! 즐거운 하루 보내세요.'),
      weekendForecast: _safeString(json['weekend_forecast'], '다가오는 주말, 두 분의 관계에 긍정적인 기운이 가득할 거예요.'),
      monthlyLuckyDay: _safeString(json['monthly_lucky_day'], '다음 달에는 새로운 기회가 찾아올 것입니다.'),
    );
  }
}
