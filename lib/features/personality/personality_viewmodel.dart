import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart'; // sharedPreferencesProvider를 위해 import
import 'package:shared_preferences/shared_preferences.dart';

// 테스트 진행 상태
enum TestStatus { loading, notStarted, inProgress, finished }

// 테스트 결과 타입
enum PersonalityType { companion, adventurer, balancer }

// 테스트 상태를 관리하는 클래스
class PersonalityTestState {
  final TestStatus status;
  final int currentQuestionIndex;
  final List<String> answers;
  final PersonalityType? result;

  PersonalityTestState({
    this.status = TestStatus.loading, // 초기 상태를 '로딩'으로 변경
    this.currentQuestionIndex = 0,
    this.answers = const [],
    this.result,
  });

  PersonalityTestState copyWith({
    TestStatus? status,
    int? currentQuestionIndex,
    List<String>? answers,
    PersonalityType? result,
  }) {
    return PersonalityTestState(
      status: status ?? this.status,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      result: result ?? this.result,
    );
  }
}

class PersonalityViewModel extends Notifier<PersonalityTestState> {
  late SharedPreferences _prefs;
  static const _resultKey = 'personality_result'; // 저장소 키

  @override
  PersonalityTestState build() {
    _prefs = ref.read(sharedPreferencesProvider);
    // ViewModel이 처음 생성될 때 저장된 결과를 불러옵니다.
    Future.microtask(() => loadResult());
    return PersonalityTestState();
  }

  // 저장된 결과를 불러오는 함수
  Future<void> loadResult() async {
    final resultString = _prefs.getString(_resultKey);
    if (resultString != null) {
      // 저장된 결과가 있으면 '완료' 상태로 바로 전환
      final result = PersonalityType.values.byName(resultString);
      state = state.copyWith(status: TestStatus.finished, result: result);
    } else {
      // 저장된 결과가 없으면 '시작 전' 상태로 전환
      state = state.copyWith(status: TestStatus.notStarted);
    }
  }

  void startTest() {
    state = state.copyWith(status: TestStatus.inProgress, currentQuestionIndex: 0, answers: []);
  }

  void answerQuestion(String answer) {
    final newAnswers = List<String>.from(state.answers)..add(answer);
    if (state.currentQuestionIndex < 9) { // 10번째 질문 전까지
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        answers: newAnswers,
      );
    } else {
      // 마지막 질문에 답하면 결과를 계산하고 저장합니다.
      _calculateAndSaveResult(newAnswers);
    }
  }

  void goBack() {
    if (state.currentQuestionIndex > 0) {
      final newAnswers = List<String>.from(state.answers)..removeLast();
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
        answers: newAnswers,
      );
    }
  }

  void _calculateAndSaveResult(List<String> finalAnswers) {
    final aCount = finalAnswers.where((ans) => ans == 'a').length;
    PersonalityType resultType;
    if (aCount >= 7) {
      resultType = PersonalityType.companion;
    } else if (aCount <= 3) {
      resultType = PersonalityType.adventurer;
    } else {
      resultType = PersonalityType.balancer;
    }

    // 결과를 휴대폰에 저장합니다.
    _prefs.setString(_resultKey, resultType.name);

    state = state.copyWith(status: TestStatus.finished, answers: finalAnswers, result: resultType);
  }
}

final personalityViewModelProvider = NotifierProvider<PersonalityViewModel, PersonalityTestState>(
      () => PersonalityViewModel(),
);
