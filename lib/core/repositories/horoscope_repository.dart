import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lovefortune_app/core/models/horoscope_model.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/core/services/ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

final logger = Logger();

// FutureProvider 대신, SharedPreferences 인스턴스를 받는 간단한 Provider로 변경합니다.
// 이 Provider는 main.dart에서 override되어 실제 값을 받습니다.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // 이 코드는 실행되지 않으며, override되지 않았을 경우 에러를 발생시킵니다.
  throw UnimplementedError();
});

final horoscopeRepositoryProvider = Provider((ref) {
  final aiService = ref.read(aiServiceProvider);
  // 이제 watch를 사용해도 안전하게 SharedPreferences 인스턴스를 가져올 수 있습니다.
  final sharedPreferences = ref.watch(sharedPreferencesProvider);

  return HoroscopeRepository(aiService, sharedPreferences);
});

class HoroscopeRepository {
  final AIService _aiService;
  final SharedPreferences _prefs;

  HoroscopeRepository(this._aiService, this._prefs);

  Future<HoroscopeModel> getHoroscope(ProfileModel myProfile, ProfileModel partnerProfile) async {
    final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final cachedDate = _prefs.getString('cached_date');
    final cachedMyBirth = _prefs.getString('cached_my_birth');
    final cachedPartnerBirth = _prefs.getString('cached_partner_birth');
    final cachedPartnerId = _prefs.getString('cached_partner_id');
    final cachedHoroscopeJson = _prefs.getString('cached_horoscope');

    final myBirthString = DateFormat('yyyy-MM-dd').format(myProfile.birthdate);
    final partnerBirthString = DateFormat('yyyy-MM-dd').format(partnerProfile.birthdate);

    if (cachedDate == todayString &&
        cachedMyBirth == myBirthString &&
        cachedPartnerBirth == partnerBirthString &&
        cachedPartnerId == partnerProfile.id &&
        cachedHoroscopeJson != null)
    {
      logger.i('✅ 캐시된 운세 데이터를 반환합니다.');
      return HoroscopeModel.fromJson(jsonDecode(cachedHoroscopeJson));
    }

    logger.i('🔄 새로운 운세 데이터를 API로부터 가져옵니다.');
    final horoscope = await _aiService.getHoroscope(myBirthString, partnerBirthString);

    await _prefs.setString('cached_date', todayString);
    await _prefs.setString('cached_my_birth', myBirthString);
    await _prefs.setString('cached_partner_birth', partnerBirthString);
    await _prefs.setString('cached_partner_id', partnerProfile.id);
    await _prefs.setString('cached_horoscope', jsonEncode(horoscope.toJson()));
    logger.i('📥 새로운 운세 데이터를 캐시에 저장했습니다.');

    return horoscope;
  }

  Future<void> clearHoroscopeCache() async {
    await _prefs.remove('cached_date');
    await _prefs.remove('cached_my_birth');
    await _prefs.remove('cached_partner_birth');
    await _prefs.remove('cached_partner_id');
    await _prefs.remove('cached_horoscope');
    logger.w('🗑️ 운세 캐시가 삭제되었습니다.');
  }
}
