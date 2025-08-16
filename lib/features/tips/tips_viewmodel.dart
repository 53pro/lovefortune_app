import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/repositories/tips_repository.dart';
import 'package:logger/logger.dart';
import 'package:lovefortune_app/core/models/conflict_topic_model.dart';

final logger = Logger();

class TipsState {
  final bool isLoading;
  final String? weeklyQuestion;
  final List<ConflictTopicModel> conflictTopics; // 갈등 주제 목록 상태 추가
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

  @override
  TipsState build() {
    _tipsRepo = ref.read(tipsRepositoryProvider);
    return TipsState();
  }

  Future<void> fetchTips() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    logger.i('TipsViewModel: 데이터 요청 시작...');
    try {
      // 주간 질문과 갈등 주제를 함께 불러옵니다.
      final question = await _tipsRepo.getWeeklyQuestion();
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
}

final tipsViewModelProvider = NotifierProvider<TipsViewModel, TipsState>(
      () => TipsViewModel(),
);
