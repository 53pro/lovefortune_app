import 'dart:convert';
import 'dart:math';
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
  Future<String> getWeeklyQuestion(ProfileModel myProfile, ProfileModel partnerProfile) async {
    logger.i('--- 주간 질문 가져오기 시작 ---');
    final now = DateTime.now();
    final weekOfYear = _getWeekOfYear(now);
    final currentWeekKey = '${now.year}-$weekOfYear';
    logger.d('이번 주 Key: $currentWeekKey');

    final cachedWeekKey = _prefs.getString('cached_week_key');
    final cachedQuestion = _prefs.getString('cached_question');
    logger.d('캐시된 주 Key: $cachedWeekKey');

    if (cachedWeekKey == currentWeekKey && cachedQuestion != null) {
      logger.i('✅ 캐시된 주간 질문을 반환합니다: $cachedQuestion');
      return cachedQuestion;
    }

    logger.i('🔄 AI로부터 새로운 주간 질문을 생성합니다.');
    try {
      final myBirthString = DateFormat('yyyy-MM-dd').format(myProfile.birthdate);
      final partnerBirthString = DateFormat('yyyy-MM-dd').format(partnerProfile.birthdate);

      // Firestore 대신 AIService를 호출합니다.
      final newQuestion = await _aiService.getWeeklyQuestion(myBirthString, partnerBirthString);
      logger.d('AI가 생성한 질문: $newQuestion');

      await _prefs.setString('cached_week_key', currentWeekKey);
      await _prefs.setString('cached_question', newQuestion);
      logger.i('📥 새로운 주간 질문을 캐시에 저장했습니다.');

      return newQuestion;
    } catch (e) {
      logger.e('AI로부터 질문을 생성하는 중 에러 발생:', error: e);
      throw Exception('AI로부터 질문을 생성하는 데 실패했습니다.');
    }
  }

  Future<List<ConflictTopicModel>> getTodaysConflictTopics() async {
    logger.i('--- 오늘의 갈등 주제 가져오기 시작 ---');
    final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final cachedDate = _prefs.getString('conflict_cached_date');
    logger.d('오늘 날짜: $todayString, 캐시된 날짜: $cachedDate');

    final cachedTopicsJson = _prefs.getString('conflict_cached_topics');
    if (cachedDate == todayString && cachedTopicsJson != null) {
      logger.i('✅ 캐시된 갈등 해결 주제를 반환합니다.');
      final List<dynamic> decoded = jsonDecode(cachedTopicsJson);
      return decoded.map((data) => ConflictTopicModel.fromMap(Map<String, dynamic>.from(data), data['id'])).toList();
    }

    logger.i('🔄 Firebase에서 새로운 갈등 해결 주제를 가져옵니다.');
    try {
      final querySnapshot = await _firestore.collection('conflict_topics').get();
      logger.d('Firestore에서 ${querySnapshot.docs.length}개의 문서를 찾았습니다.');
      if (querySnapshot.docs.isNotEmpty) {
        logger.d('첫 번째 문서 내용: ${querySnapshot.docs.first.data()}');
      }

      final allTopics = querySnapshot.docs.map((doc) => ConflictTopicModel.fromMap(doc.data(), doc.id)).toList();
      logger.d('모델로 변환된 주제 개수: ${allTopics.length}개');

      if (allTopics.isEmpty) {
        logger.w('Firestore에 갈등 주제 데이터가 없습니다.');
        return [];
      }

      allTopics.shuffle();
      final selectedTopics = allTopics.take(3).toList();

      final topicsToCache = selectedTopics.map((t) => {'id': t.id, 'category': t.category, 'topic': t.topic}).toList();
      await _prefs.setString('conflict_cached_date', todayString);
      await _prefs.setString('conflict_cached_topics', jsonEncode(topicsToCache));
      logger.i('📥 새로운 갈등 해결 주제를 캐시에 저장했습니다.');

      return selectedTopics;
    } catch (e) {
      logger.e('Firebase에서 갈등 주제를 가져오는 중 에러 발생:', error: e);
      throw Exception('Firebase에서 갈등 주제를 가져오는 데 실패했습니다.');
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

    final cachedDate = _prefs.getString('self_tip_cached_date');
    final cachedMyBirth = _prefs.getString('self_tip_my_birth');
    final cachedTipJson = _prefs.getString('self_tip_data');

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
    await _prefs.setString('self_tip_cached_date', todayString);
    await _prefs.setString('self_tip_my_birth', myBirthString);
    await _prefs.setString('self_tip_data', jsonEncode(tip.toJson()));
    logger.i('📥 새로운 자기 발견 팁을 캐시에 저장했습니다.');

    return tip;
  }

}
