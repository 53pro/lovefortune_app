import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/horoscope_model.dart';
// 이 import 구문이 정확히 있는지 확인해주세요!
import 'package:lovefortune_app/core/services/ai_service.dart';

final horoscopeRepositoryProvider = Provider((ref) {
  // 여기서 aiServiceProvider를 사용합니다.
  final aiService = ref.read(aiServiceProvider);
  return HoroscopeRepository(aiService);
});

class HoroscopeRepository {
  final AIService _aiService;

  HoroscopeRepository(this._aiService);

  Future<HoroscopeModel> getHoroscope(String userBirth, String partnerBirth) async {
    try {
      final horoscope = await _aiService.getHoroscope(userBirth, partnerBirth);
      return horoscope;
    } catch (e) {
      rethrow;
    }
  }
}