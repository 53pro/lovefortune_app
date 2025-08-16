import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lovefortune_app/core/models/conflict_topic_model.dart';
import 'package:lovefortune_app/core/models/personality_report_model.dart';
import 'package:lovefortune_app/core/repositories/profile_repository.dart';
import 'package:lovefortune_app/core/repositories/tips_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart';
import 'package:logger/logger.dart';

final logger = Logger();

// 캐시 확인 결과를 담을 클래스
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
  late SharedPreferences _prefs;
  late HoroscopeRepository _horoscopeRepo;

  @override
  TipsState build() {
    _tipsRepo = ref.read(tipsRepositoryProvider);
    _profileRepo = ref.read(profileRepositoryProvider);
    _prefs = ref.read(sharedPreferencesProvider);
    _horoscopeRepo = ref.read(horoscopeRepositoryProvider);
    return TipsState();
  }

  Future<void> fetchTips() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final question = await _tipsRepo.getWeeklyQuestion();
      final topics = await _tipsRepo.getTodaysConflictTopics();
      state = state.copyWith(isLoading: false, weeklyQuestion: question, conflictTopics: topics);
    } catch (e) {
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
}

final tipsViewModelProvider = NotifierProvider<TipsViewModel, TipsState>(
      () => TipsViewModel(),
);
