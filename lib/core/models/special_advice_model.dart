// lib/core/models/special_advice_model.dart
import 'package:logger/logger.dart';

final logger = Logger();

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
    // 데이터 파싱 과정을 추적하기 위해 로그를 추가합니다.
    logger.d('SpecialAdviceModel 파싱 시작...', error: json);

    // 다국어 지원을 위해 AI가 보내준 키를 영어로 수정합니다.
    final secretCode = json['secret_code'] as Map<String, dynamic>? ?? {};
    final futurePeek = json['future_peek'] as Map<String, dynamic>? ?? {};

    logger.d('secretCode 파싱 결과:', error: secretCode);
    logger.d('futurePeek 파싱 결과:', error: futurePeek);

    final model = SpecialAdviceModel(
      synergyPoint: secretCode['synergy_point'] as String? ?? '오늘은 함께 조용한 시간을 보내며 서로에게 집중해보세요.',
      conflictWarning: secretCode['conflict_warning'] as String? ?? '오늘은 특별히 주의할 점이 없네요! 즐거운 하루 보내세요.',
      weekendForecast: futurePeek['weekend_forecast'] as String? ?? '다가오는 주말, 두 분의 관계에 긍정적인 기운이 가득할 거예요.',
      monthlyLuckyDay: futurePeek['monthly_lucky_day'] as String? ?? '다음 달에는 새로운 기회가 찾아올 것입니다.',
    );

    logger.i('✅ SpecialAdviceModel 파싱 성공!');
    return model;
  }
}
