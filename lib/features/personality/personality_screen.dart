import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/features/main/main_screen.dart';
import 'package:lovefortune_app/features/personality/personality_viewmodel.dart';

// --- 심리테스트 데이터 ---
const _questions = [
  {"q": "꿈에 그리던 이상형과 첫 데이트! 어떤 장소로 향하고 싶나요?", "a": "분위기 좋은 레스토랑에서 즐기는 맛있는 저녁 식사", "b": "함께 웃고 즐길 수 있는 활동적인 테마파크"},
  {"q": "연인과 사소한 다툼을 했을 때, 당신의 행동은?", "a": "먼저 다가가 대화로 차근차근 풀려고 노력한다.", "b": "잠시 혼자만의 시간을 가지며 감정을 정리한다."},
  {"q": "연인에게 줄 깜짝 선물을 고른다면?", "a": "상대방이 평소에 갖고 싶어 했던 실용적인 선물", "b": "나의 마음이 담긴 정성스러운 손편지와 작은 꽃다발"},
  {"q": "연인과의 주말 데이트, 갑자기 비가 온다면?", "a": "\"아쉽지만 어쩔 수 없지!\" 실내에서 할 수 있는 다른 계획을 빠르게 세운다.", "b": "\"비 오는 것도 운치 있네!\" 함께 비를 맞으며 새로운 추억을 만든다."},
  {"q": "연인이 힘들어 보일 때, 당신이 해주고 싶은 위로는?", "a": "\"무슨 일이야? 해결할 방법이 있을 거야.\" 구체적인 해결책을 함께 고민해 준다.", "b": "\"많이 힘들었겠다.\" 말없이 곁을 지키며 따뜻하게 안아준다."},
  {"q": "두 사람의 1주년 기념일, 어떻게 보내고 싶나요?", "a": "평소 가보지 못했던 특별한 곳으로 떠나는 둘만의 여행", "b": "소중한 친구들과 함께하는 즐거운 기념일 파티"},
  {"q": "연인과 함께 있을 때, 당신이 더 행복한 순간은?", "a": "서로의 미래에 대한 진지한 이야기를 나누며 공감대를 형성할 때", "b": "아무 말 없이도 편안함을 느끼며 각자의 시간을 보낼 때"},
  {"q": "연인이 나와 다른 취미에 푹 빠져있다면?", "a": "\"재미있어 보이네! 나도 한번 배워볼까?\" 호기심을 보이며 함께 즐기려 노력한다.", "b": "\"혼자만의 시간도 중요하지.\" 각자의 취미 생활을 존중하고 응원해 준다."},
  {"q": "연인과의 관계에서 가장 중요하다고 생각하는 것은?", "a": "서로에 대한 변치 않는 믿음과 신뢰", "b": "함께 있을 때 느끼는 설렘과 열정"},
  {"q": "10년 후, 연인과 함께하는 당신의 모습을 상상한다면?", "a": "안정적인 일상 속에서 서로에게 가장 편안한 친구처럼 지내는 모습", "b": "여전히 새로운 도전을 함께하며 세상을 탐험하는 모험가 같은 모습"}
];

const _results = {
  PersonalityType.companion: {
    "type": "'따뜻한 동반자' 타입",
    "description": "연애에 있어 가장 중요한 것은 서로에 대한 믿음과 편안함이라고 생각하는군요. 당신은 계획을 세워 함께 미래를 그려나가는 것에서 큰 행복을 느끼며, 연인에게 든든한 버팀목이 되어주는 사람입니다. 때로는 즉흥적인 즐거움도 함께한다면 관계가 더욱 풍성해질 거예요.",
    "keywords": ["#계획적", "#안정지향", "#신뢰"],
  },
  PersonalityType.adventurer: {
    "type": "'열정적인 모험가' 타입",
    "description": "당신에게 연애는 함께 떠나는 신나는 모험과도 같습니다. 정해진 계획보다는 즉흥적인 감정과 새로운 경험을 통해 관계의 활력을 얻는군요. 당신의 넘치는 에너지는 연인에게도 긍정적인 영향을 주지만, 때로는 차분히 서로의 속마음을 나누는 시간도 필요해요.",
    "keywords": ["#즉흥적", "#감성중시", "#낭만"],
  },
  PersonalityType.balancer: {
    "type": "'조화로운 파트너' 타입",
    "description": "당신은 안정적인 관계의 중요성을 알면서도, 함께하는 즐거운 순간과 설렘을 놓치고 싶어 하지 않는군요. 상황에 따라 계획을 세우기도, 즉흥적인 즐거움을 택하기도 하는 당신의 유연함은 관계를 건강하게 만드는 가장 큰 장점입니다.",
    "keywords": ["#유연함", "#균형감각", "#공감"],
  },
};
// --------------------------

class PersonalityScreen extends ConsumerWidget {
  const PersonalityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(personalityViewModelProvider);
    final viewModel = ref.read(personalityViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        // AppBar의 제목을 '오늘 우리는'으로 고정합니다.
        title: const Text('오늘 우리는'),
      ),
      body: switch (state.status) {
        TestStatus.notStarted => _buildStartView(viewModel),
        TestStatus.inProgress => _buildTestView(state, viewModel),
        TestStatus.finished => _buildResultView(context, ref, state.result!),
      },
    );
  }

  Widget _buildStartView(PersonalityViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology, size: 80, color: Color(0xFF5B86E5)),
            const SizedBox(height: 24),
            const Text(
              '나의 연애 성향 알아보기',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '간단한 테스트를 통해 당신의 연애 스타일을 발견하고\n맞춤형 조언을 확인해보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: viewModel.startTest,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text('테스트 시작하기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestView(PersonalityTestState state, PersonalityViewModel viewModel) {
    final question = _questions[state.currentQuestionIndex];
    final progress = (state.currentQuestionIndex + 1) / _questions.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Q${state.currentQuestionIndex + 1}.',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B86E5),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  question['q']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.5),
                ),
                const SizedBox(height: 32),
                _AnswerButton(
                  text: question['a']!,
                  onPressed: () => viewModel.answerQuestion('a'),
                ),
                const SizedBox(height: 12),
                _AnswerButton(
                  text: question['b']!,
                  onPressed: () => viewModel.answerQuestion('b'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView(BuildContext context, WidgetRef ref, PersonalityType result) {
    final resultData = _results[result]!;
    final viewModel = ref.read(personalityViewModelProvider.notifier);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      '당신의 연애 성향은...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      resultData['type']! as String,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5B86E5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      alignment: WrapAlignment.center,
                      children: (resultData['keywords'] as List<String>)
                          .map((keyword) => Chip(label: Text(keyword)))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      resultData['description']! as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, height: 1.7, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(mainScreenIndexProvider.notifier).state = 1;
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text('오늘우리 운세 보러가기'),
            ),
            const SizedBox(height: 12),
            // '다시 테스트하기' 버튼을 추가합니다.
            TextButton(
              onPressed: () {
                // ViewModel의 startTest 함수를 호출하여 테스트를 리셋합니다.
                viewModel.startTest();
              },
              child: const Text('연애 성향 다시 테스트하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _AnswerButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        child: Text(text),
      ),
    );
  }
}
