import 'package:flutter_riverpod/flutter_riverpod.dart';

// 테스트 진행 상태
enum TestStatus { notStarted, inProgress, finished }

// 테스트 결과 타입
enum PersonalityType { companion, adventurer, balancer }

// 테스트 상태를 관리하는 클래스
class PersonalityTestState {
  final TestStatus status;
  final int currentQuestionIndex;
  final List<String> answers;
  final PersonalityType? result;

  PersonalityTestState({
    this.status = TestStatus.notStarted,
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
  @override
  PersonalityTestState build() {
    return PersonalityTestState();
  }

  void startTest() {
    state = state.copyWith(status: TestStatus.inProgress, currentQuestionIndex: 0, answers: []);
  }

  void answerQuestion(String answer) {
    final newAnswers = List<String>.from(state.answers)..add(answer);
    if (state.currentQuestionIndex < 9) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        answers: newAnswers,
      );
    } else {
      _calculateResult(newAnswers);
    }
  }

  void _calculateResult(List<String> finalAnswers) {
    final aCount = finalAnswers.where((ans) => ans == 'a').length;
    PersonalityType resultType;
    if (aCount >= 7) {
      resultType = PersonalityType.companion;
    } else if (aCount <= 3) {
      resultType = PersonalityType.adventurer;
    } else {
      resultType = PersonalityType.balancer;
    }
    state = state.copyWith(status: TestStatus.finished, answers: finalAnswers, result: resultType);
  }
}

final personalityViewModelProvider = NotifierProvider<PersonalityViewModel, PersonalityTestState>(
      () => PersonalityViewModel(),
);
