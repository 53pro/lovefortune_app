import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/conflict_topic_model.dart';
import 'package:lovefortune_app/core/models/personality_report_model.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/core/repositories/profile_repository.dart';
import 'package:lovefortune_app/core/repositories/tips_repository.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart';
import 'package:lovefortune_app/core/models/conflict_guide_model.dart';


final logger = Logger();

// 캐시 확인 결과를 담을 클래스 (추가)
class ReportCheckResult {
  final bool needsApiCall;
  final PersonalityReportModel? cachedReport;
  ReportCheckResult({required this.needsApiCall, this.cachedReport});
}

class TipsState {
  final bool isLoading;
  final String? weeklyQuestion;
  final List<ConflictTopicModel> conflictTopics;
  final String? errorMessage;

  TipsState({
    this.isLoading = false,
    this.weeklyQuestion,
    this.conflictTopics = const [],
    this.errorMessage,
  });

  TipsState copyWith({
    bool? isLoading,
    String? weeklyQuestion,
    List<ConflictTopicModel>? conflictTopics,
    String? errorMessage,
  }) {
    return TipsState(
      isLoading: isLoading ?? this.isLoading,
      weeklyQuestion: weeklyQuestion ?? this.weeklyQuestion,
      conflictTopics: conflictTopics ?? this.conflictTopics,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TipsViewModel extends Notifier<TipsState> {
  late TipsRepository _tipsRepo;
  late ProfileRepository _profileRepo;
  late HoroscopeRepository _horoscopeRepo;
  late SharedPreferences _prefs;


  @override
  TipsState build() {
    _tipsRepo = ref.read(tipsRepositoryProvider);
    _profileRepo = ref.read(profileRepositoryProvider);
    _horoscopeRepo = ref.read(horoscopeRepositoryProvider);
    _prefs = ref.read(sharedPreferencesProvider);
    return TipsState();
  }

  Future<void> fetchTips() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    logger.i('TipsViewModel: 데이터 요청 시작...');
    try {
      // 주간 질문을 요청하기 위해 프로필 정보를 먼저 가져옵니다.
      final myProfile = await _profileRepo.getMyProfile();
      final partnerProfile = await _profileRepo.getSelectedPartner();

      if (myProfile == null || partnerProfile == null) {
        throw Exception('주간 질문을 보려면 프로필 정보가 필요합니다.');
      }

      // 주간 질문과 갈등 주제를 함께 불러옵니다.
      final question = await _tipsRepo.getWeeklyQuestion(myProfile, partnerProfile);
      final topics = await _tipsRepo.getTodaysConflictTopics();

      logger.d('TipsViewModel: Repository로부터 질문 수신 완료: $question');
      logger.d('TipsViewModel: Repository로부터 갈등 주제 ${topics.length}개 수신 완료');

      state = state.copyWith(isLoading: false, weeklyQuestion: question, conflictTopics: topics);
      logger.i('✅ TipsViewModel: 상태 업데이트 성공!');
    } catch (e) {
      logger.e('TipsViewModel: 데이터 요청 실패', error: e);
      state = state.copyWith(isLoading: false, errorMessage: '팁을 불러오는 데 실패했습니다.');
    }
  }

  // API 호출이 필요한지 미리 확인하는 함수
  Future<ReportCheckResult> checkNeedsApiCall() async {
    final myProfile = await _profileRepo.getMyProfile();
    final partnerProfile = await _profileRepo.getSelectedPartner();

    if (myProfile == null || partnerProfile == null) {
      throw Exception('프로필 정보가 필요합니다.');
    }

    final myBirthString = DateFormat('yyyy-MM-dd').format(myProfile.birthdate);
    final cachedMyBirth = _prefs.getString('report_my_birth');
    final cachedPartnerId = _prefs.getString('report_partner_id');
    final cachedReportJson = _prefs.getString('report_data');

    if (cachedMyBirth == myBirthString && cachedPartnerId == partnerProfile.id && cachedReportJson != null) {
      return ReportCheckResult(
        needsApiCall: false,
        cachedReport: PersonalityReportModel.fromJson(jsonDecode(cachedReportJson)),
      );
    } else {
      return ReportCheckResult(needsApiCall: true);
    }
  }

  // 관계 설명서를 가져오는 함수
  Future<PersonalityReportModel> fetchPersonalityReport() async {
    logger.i('TipsViewModel: 관계 설명서 미리 가져오기 시작...');
    final myProfile = await _profileRepo.getMyProfile();
    final partnerProfile = await _profileRepo.getSelectedPartner();
    if (myProfile == null || partnerProfile == null) {
      throw Exception('프로필 정보가 필요합니다.');
    }
    return _tipsRepo.getPersonalityReport(myProfile, partnerProfile);
  }

  // 갈등 해결 가이드를 미리 요청하고, Future를 반환하는 함수
  Future<ConflictGuideModel> fetchConflictGuide(String topic) async {
    logger.i('TipsViewModel: 갈등 해결 가이드 미리 가져오기 시작...');
    final myProfile = await _profileRepo.getMyProfile();
    final partnerProfile = await _profileRepo.getSelectedPartner();

    if (myProfile == null || partnerProfile == null) {
      throw Exception('프로필 정보가 없어 가이드를 볼 수 없습니다.');
    }

    return _horoscopeRepo.getConflictGuide(myProfile, partnerProfile, topic);
  }
}

final tipsViewModelProvider = NotifierProvider<TipsViewModel, TipsState>(
      () => TipsViewModel(),
);
