import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lovefortune_app/core/models/horoscope_model.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/core/models/special_advice_model.dart';
import 'package:lovefortune_app/core/services/ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:lovefortune_app/core/models/self_discovery_model.dart';
import 'package:lovefortune_app/core/models/personality_report_model.dart';
import 'package:lovefortune_app/core/models/conflict_guide_model.dart';

final logger = Logger();

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final horoscopeRepositoryProvider = Provider((ref) {
  final aiService = ref.read(aiServiceProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return HoroscopeRepository(aiService, sharedPreferences);
});

class HoroscopeRepository {
  final AIService _aiService;
  final SharedPreferences _prefs;

  HoroscopeRepository(this._aiService, this._prefs);

  Future<HoroscopeModel> getHoroscope(ProfileModel myProfile, ProfileModel partnerProfile) async {
    final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final myBirthString = DateFormat('yyyy-MM-dd').format(myProfile.birthdate);
    final partnerBirthString = DateFormat('yyyy-MM-dd').format(partnerProfile.birthdate);

    final cachedDate = _prefs.getString('cached_date');
    final cachedMyBirth = _prefs.getString('cached_my_birth');
    final cachedPartnerBirth = _prefs.getString('cached_partner_birth');
    final cachedPartnerId = _prefs.getString('cached_partner_id');
    final cachedHoroscopeJson = _prefs.getString('cached_horoscope');

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

  // 스페셜 조언을 요청하는 새로운 함수
  Future<SpecialAdviceModel> getSpecialAdvice(ProfileModel myProfile, ProfileModel partnerProfile) {
    logger.i('Repository에서 AIService로 스페셜 조언 요청 전달...');
    final myBirthString = DateFormat('yyyy-MM-dd').format(myProfile.birthdate);
    final partnerBirthString = DateFormat('yyyy-MM-dd').format(partnerProfile.birthdate);
    return _aiService.getSpecialAdvice(myBirthString, partnerBirthString);
  }

  Future<void> clearHoroscopeCache() async {
    await _prefs.remove('cached_date');
    await _prefs.remove('cached_my_birth');
    await _prefs.remove('cached_partner_birth');
    await _prefs.remove('cached_partner_id');
    await _prefs.remove('cached_horoscope');
    logger.w('🗑️ 운세 캐시가 삭제되었습니다.');
  }

  // 자기 발견 팁을 요청하는 새로운 함수 추가
  Future<SelfDiscoveryModel> getSelfDiscoveryTip(ProfileModel myProfile) {
    final myBirthString = DateFormat('yyyy-MM-dd').format(myProfile.birthdate);
    return _aiService.getSelfDiscoveryTip(myBirthString);
  }

  // 성향 분석 리포트를 요청하는 새로운 함수 (추가)
  Future<PersonalityReportModel> getPersonalityReport(ProfileModel myProfile, ProfileModel partnerProfile) {
    final myBirthString = DateFormat('yyyy-MM-dd').format(myProfile.birthdate);
    final partnerBirthString = DateFormat('yyyy-MM-dd').format(partnerProfile.birthdate);
    return _aiService.getPersonalityReport(myBirthString, partnerBirthString);
  }

  // 갈등 해결 가이드를 요청하는 새로운 함수 (반환 타입 수정)
  Future<ConflictGuideModel> getConflictGuide(ProfileModel myProfile, ProfileModel partnerProfile, String topic) {
    logger.i('HoroscopeRepository: AIService에 갈등 해결 가이드 요청 전달...');
    final myBirthString = DateFormat('yyyy-MM-dd').format(myProfile.birthdate);
    final partnerBirthString = DateFormat('yyyy-MM-dd').format(partnerProfile.birthdate);
    return _aiService.getConflictGuide(myBirthString, partnerBirthString, topic);
  }

}
