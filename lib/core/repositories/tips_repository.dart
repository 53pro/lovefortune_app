import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/conflict_topic_model.dart';
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

final logger = Logger();

final tipsRepositoryProvider = Provider((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return TipsRepository(FirebaseFirestore.instance, sharedPreferences);
});

class TipsRepository {
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;

  TipsRepository(this._firestore, this._prefs);

  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays;
    return (dayOfYear / 7).ceil();
  }

  Future<String> getWeeklyQuestion() async {
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

    logger.i('🔄 Firebase에서 새로운 주간 질문을 가져옵니다.');
    try {
      final querySnapshot = await _firestore.collection('weekly_questions').get();
      final questions = querySnapshot.docs.map((doc) => doc.data()['question'] as String).toList();
      logger.d('Firestore에서 ${questions.length}개의 질문을 찾았습니다.');

      if (questions.isEmpty) {
        logger.w('Firestore에 질문 데이터가 없습니다. 기본 질문을 반환합니다.');
        return "서로에게 가장 고마웠던 순간은 언제인가요?";
      }

      final randomQuestion = questions[Random().nextInt(questions.length)];
      logger.d('랜덤 선택된 질문: $randomQuestion');

      await _prefs.setString('cached_week_key', currentWeekKey);
      await _prefs.setString('cached_question', randomQuestion);
      logger.i('📥 새로운 주간 질문을 캐시에 저장했습니다.');

      return randomQuestion;
    } catch (e) {
      logger.e('Firebase에서 질문을 가져오는 중 에러 발생:', error: e);
      throw Exception('Firebase에서 질문을 가져오는 데 실패했습니다.');
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
      // Firestore에서 가져온 문서의 개수와 내용을 직접 로그로 확인합니다.
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
}
