import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lovefortune_app/core/models/conflict_topic_model.dart';
import 'package:lovefortune_app/core/models/personality_report_model.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/core/models/self_discovery_model.dart';
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart';
import 'package:lovefortune_app/core/services/ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

final logger = Logger();

final tipsRepositoryProvider = Provider((ref) {
  final aiService = ref.read(aiServiceProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return TipsRepository(FirebaseFirestore.instance, sharedPreferences, aiService);
});

class TipsRepository {
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;
  final AIService _aiService;

  TipsRepository(this._firestore, this._prefs, this._aiService);

  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays;
    return (dayOfYear / 7).ceil();
  }

  // 이제 ProfileModel을 인자로 받아 AI에게 전달합니다.
  Future<String> getTodaysQuestion(ProfileModel myProfile, ProfileModel partnerProfile, {bool forceRefresh = false}) async {
    logger.i('--- 질문 가져오기 시작 (forceRefresh: $forceRefresh) ---');
    final now = DateTime.now();
    final todayString = DateFormat('yyyy-MM-dd').format(now);
    logger.d('오늘 날짜 Key: $todayString');

    final cachedDateKey = _prefs.getString('cached_question_date');
    final cachedQuestion = _prefs.getString('cached_question');
    logger.d('캐시된 질문 날짜 Key: $cachedDateKey');

    if (!forceRefresh && cachedDateKey == todayString && cachedQuestion != null) {
      logger.i('✅ 캐시된 질문을 반환합니다: $cachedQuestion');
      return cachedQuestion;
    }

    logger.i('🔄 AI로부터 새로운 질문을 생성합니다.');
    try {
      final myBirthString = DateFormat('yyyy-MM-dd').format(myProfile.birthdate);
      final partnerBirthString = DateFormat('yyyy-MM-dd').format(partnerProfile.birthdate);

      // Firestore 대신 AIService를 호출합니다.
      final newQuestion = await _aiService.getTodaysQuestion(myBirthString, partnerBirthString);
      logger.d('AI가 생성한 질문: $newQuestion');

      await _prefs.setString('cached_question_date', todayString);
      await _prefs.setString('cached_question', newQuestion);
      logger.i('📥 새로운 질문을 캐시에 저장했습니다.');

      return newQuestion;
    } catch (e) {
      logger.e('AI로부터 질문을 생성하는 중 에러 발생:', error: e);
      throw Exception('AI로부터 질문을 생성하는 데 실패했습니다.');
    }
  }

  Future<List<ConflictTopicModel>> getTodaysConflictTopics(
      ProfileModel myProfile, ProfileModel partnerProfile, {bool forceRefresh = false}) async {
    logger.i('--- 오늘의 갈등 주제 가져오기 시작 (forceRefresh: $forceRefresh) ---');
    final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final cachedDate = _prefs.getString('conflict_cached_date');
    logger.d('오늘 날짜: $todayString, 캐시된 날짜: $cachedDate');

    final cachedTopicsJson = _prefs.getString('conflict_cached_topics');
    if (!forceRefresh && cachedDate == todayString && cachedTopicsJson != null) {
      logger.i('✅ 캐시된 갈등 해결 주제를 반환합니다.');
      final List<dynamic> decoded = jsonDecode(cachedTopicsJson);
      return decoded.map((data) => ConflictTopicModel.fromMap(Map<String, dynamic>.from(data), data['id'] ?? '')).toList();
    }

    logger.i('🔄 AI로부터 새로운 갈등 해결 주제를 가져옵니다.');
    try {
      final myBirthString = DateFormat('yyyy-MM-dd').format(myProfile.birthdate);
      final partnerBirthString = DateFormat('yyyy-MM-dd').format(partnerProfile.birthdate);

      final topicsList = await _aiService.getTodaysConflictTopics(myBirthString, partnerBirthString);
      logger.d('AI가 생성한 갈등 주제: $topicsList');

      await _prefs.setString('conflict_cached_date', todayString);
      await _prefs.setString('conflict_cached_topics', jsonEncode(topicsList));
      logger.i('📥 새로운 갈등 해결 주제를 캐시에 저장했습니다.');

      return topicsList.map((t) => ConflictTopicModel.fromMap(t, t['id'] ?? '')).toList();
    } catch (e) {
      logger.e('AI에서 갈등 주제를 가져오는 중 에러 발생:', error: e);
      throw Exception('AI에서 갈등 주제를 가져오는 데 실패했습니다.');
    }
  }

  // 새로운 갈등 해결 가이드 추가 API (하루 한 번 제한)
  Future<List<ConflictTopicModel>> addAdditionalConflictTopic(
      ProfileModel myProfile, ProfileModel partnerProfile) async {
    logger.i('--- 새로운 갈등 주제 추가 시작 ---');
    final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastAddedDate = _prefs.getString('conflict_last_added_date');

    if (lastAddedDate == todayString) {
      logger.w('⚠️ 이미 오늘 새로운 갈등 해결 가이드를 추가했습니다.');
      throw Exception('새로운 가이드는 하루에 한 번만 추가할 수 있습니다.');
    }

    try {
      final myBirthString = DateFormat('yyyy-MM-dd').format(myProfile.birthdate);
      final partnerBirthString = DateFormat('yyyy-MM-dd').format(partnerProfile.birthdate);

      final cachedTopicsJson = _prefs.getString('conflict_cached_topics');
      List<dynamic> topicsList = [];
      if (cachedTopicsJson != null) {
        topicsList = jsonDecode(cachedTopicsJson) as List<dynamic>;
      }

      final existingTopics = topicsList.map((t) => t['topic'] as String).toList();

      final newTopicMap = await _aiService.getAdditionalConflictTopic(myBirthString, partnerBirthString, existingTopics);
      logger.d('AI가 생성한 새로운 갈등 주제: $newTopicMap');

      final newId = (topicsList.length + 1).toString();
      final newTopicWithId = {
        'id': newId,
        'category': newTopicMap['category'] ?? '기타',
        'topic': newTopicMap['topic'] ?? '새로운 갈등 해결 주제',
      };

      topicsList.add(newTopicWithId);

      await _prefs.setString('conflict_cached_topics', jsonEncode(topicsList));
      await _prefs.setString('conflict_last_added_date', todayString);
      logger.i('📥 새로운 갈등 주제를 캐시에 추가 및 일일 제한 갱신 완료.');

      return topicsList.map((t) => ConflictTopicModel.fromMap(Map<String, dynamic>.from(t), t['id'] ?? '')).toList();
    } catch (e) {
      logger.e('AI에서 새로운 갈등 주제를 추가하는 중 에러 발생:', error: e);
      throw Exception('새로운 갈등 해결 가이드를 추가하는 데 실패했습니다.');
    }
  }

  // 관계 설명서를 가져오는 함수 (캐싱 로직 추가)
  Future<PersonalityReportModel> getPersonalityReport(ProfileModel myProfile, ProfileModel partnerProfile) async {
    final myBirthString = DateFormat('yyyy-MM-dd').format(myProfile.birthdate);
    final partnerBirthString = DateFormat('yyyy-MM-dd').format(partnerProfile.birthdate);

    // 캐시된 데이터와 현재 조건을 비교합니다.
    final cachedMyBirth = _prefs.getString('report_my_birth');
    final cachedPartnerId = _prefs.getString('report_partner_id');
    final cachedReportJson = _prefs.getString('report_data');

    // 조건이 모두 일치하면 캐시된 데이터를 반환합니다.
    if (cachedMyBirth == myBirthString &&
        cachedPartnerId == partnerProfile.id &&
        cachedReportJson != null) {
      logger.i('✅ 캐시된 관계 설명서를 반환합니다.');
      return PersonalityReportModel.fromJson(jsonDecode(cachedReportJson));
    }

    // 조건이 일치하지 않으면 API를 호출합니다.
    logger.i('🔄 새로운 관계 설명서를 API로부터 가져옵니다.');
    final report = await _aiService.getPersonalityReport(myBirthString, partnerBirthString);

    // 새로 받아온 데이터를 캐시에 저장합니다.
    await _prefs.setString('report_my_birth', myBirthString);
    await _prefs.setString('report_partner_id', partnerProfile.id);
    await _prefs.setString('report_data', jsonEncode(report.toJson())); // toJson 필요
    logger.i('📥 새로운 관계 설명서를 캐시에 저장했습니다.');

    return report;
  }
  // 자기 발견 팁을 가져오는 함수 (캐싱 로직 추가)
  Future<SelfDiscoveryModel> getSelfDiscoveryTip(ProfileModel myProfile) async {
    final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final myBirthString = DateFormat('yyyy-MM-dd').format(myProfile.birthdate);

    final cachedDate = _prefs.getString('self_tip_cached_date_v2');
    final cachedMyBirth = _prefs.getString('self_tip_my_birth_v2');
    final cachedTipJson = _prefs.getString('self_tip_data_v2');

    // 오늘 날짜와 내 생일 정보가 모두 일치하면 캐시된 데이터를 반환합니다.
    if (cachedDate == todayString &&
        cachedMyBirth == myBirthString &&
        cachedTipJson != null) {
      logger.i('✅ 캐시된 자기 발견 팁을 반환합니다.');
      return SelfDiscoveryModel.fromJson(jsonDecode(cachedTipJson));
    }

    // 조건이 일치하지 않으면 API를 호출합니다.
    logger.i('🔄 새로운 자기 발견 팁을 API로부터 가져옵니다.');
    final tip = await _aiService.getSelfDiscoveryTip(myBirthString);

    // 새로 받아온 데이터를 캐시에 저장합니다.
    await _prefs.setString('self_tip_cached_date_v2', todayString);
    await _prefs.setString('self_tip_my_birth_v2', myBirthString);
    await _prefs.setString('self_tip_data_v2', jsonEncode(tip.toJson()));
    logger.i('📥 새로운 자기 발견 팁을 캐시에 저장했습니다.');

    return tip;
  }

}
