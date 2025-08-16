import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/conflict_topic_model.dart';
import 'package:lovefortune_app/core/models/personality_report_model.dart';
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart';
import 'package:lovefortune_app/core/repositories/profile_repository.dart';
import 'package:lovefortune_app/core/repositories/tips_repository.dart';
import 'package:logger/logger.dart';

final logger = Logger();

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

  @override
  TipsState build() {
    _tipsRepo = ref.read(tipsRepositoryProvider);
    _profileRepo = ref.read(profileRepositoryProvider);
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

  // 관계 설명서를 미리 요청하고, Future를 반환하는 함수 (추가)
  Future<PersonalityReportModel> fetchPersonalityReport() async {
    logger.i('TipsViewModel: 관계 설명서 미리 가져오기 시작...');
    final myProfile = await _profileRepo.getMyProfile();
    final partnerProfile = await _profileRepo.getSelectedPartner();

    if (myProfile == null || partnerProfile == null) {
      throw Exception('프로필 정보가 없어 관계 설명서를 볼 수 없습니다.');
    }

    return _horoscopeRepo.getPersonalityReport(myProfile, partnerProfile);
  }
}

final tipsViewModelProvider = NotifierProvider<TipsViewModel, TipsState>(
      () => TipsViewModel(),
);
