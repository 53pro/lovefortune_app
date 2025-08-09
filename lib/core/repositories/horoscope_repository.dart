import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/horoscope_model.dart';
import 'package:lovefortune_app/core/services/ai_service.dart';
import 'package:lovefortune_app/features/tips/relationship_tips_model.dart'; // import 구문 추가

final horoscopeRepositoryProvider = Provider((ref) {
  final aiService = ref.read(aiServiceProvider);
  return HoroscopeRepository(aiService);
});

class HoroscopeRepository {
  final AIService _aiService;

  HoroscopeRepository(this._aiService);

  // 스트리밍이 아닌 일반 Future<HoroscopeModel>을 반환하도록 수정합니다.
  Future<HoroscopeModel> getHoroscope(String userBirth, String partnerBirth) async {
    try {
      // AIService의 getHoroscope 함수를 호출하도록 수정합니다.
      final horoscope = await _aiService.getHoroscope(userBirth, partnerBirth);
      return horoscope;
    } catch (e) {
      rethrow;
    }
  }

  // 관계 팁을 요청하는 새로운 함수 추가
  Future<RelationshipTipsModel> getRelationshipTips(String userBirth, String partnerBirth) {
    return _aiService.getRelationshipTips(userBirth, partnerBirth);
  }
}
